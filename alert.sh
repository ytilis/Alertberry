#!/bin/bash

# Function courtesy of: http://stackoverflow.com/a/26655887/165963
function parse_json() {
  local IFS=' '
  echo $1 | sed -e 's/[{}]/''/g' | awk -F=':' -v RS=',' "\$1~/\"$2\"/ {print}" | sed -e "s/\"$2\"://" | tr -d "\n\t" | sed -e 's/\\"/"/g' | sed -e 's/\\\\/\\/g' | sed -e 's/^[ \t]*//g' | sed -e 's/^"//'  -e 's/"$//'
}

function push_notify() {
  local IFS=:
  # Get the colon delimited list of people to notify
  while read NAME TOKEN || [ -n "$NAME" ]; do
    # Call Pushbullet
    OUT=$(curl --silent --show-error --write-out '\n%{http_code}' -u $TOKEN: https://api.pushbullet.com/v2/pushes -d type=note -d title="$PB_TITLE" -d body="$PB_MSG") 2>/dev/null

    # Get exit code
    RET=$?

    if [[ $RET != 0 ]] ; then
      # If error exit code, print exit code
      echo "${red}ERROR${normal}: $RET"

      # Print HTTP error
      echo "HTTP ${red}ERROR${normal}: $(echo "$OUT" | tail -n1 )"
    else
      STATUS=$(echo "$OUT" | tail -n1)    # HTTP Status
      RESPONSE=$(echo "$OUT" | head -n-1) # HTTP Body

      if [[ $STATUS == '200' ]] ; then
        # Success
        echo "  ${underline}$NAME${normal} has been alerted"
      else
        # Failure
        MESSAGE=$(parse_json "$RESPONSE" message)
        echo "  ${red}ERROR${normal}: Alerting ${underline}$NAME${normal}: $STATUS - $MESSAGE"
      fi
    fi

  done < $PB_TRGTS
}

# Import configs
source alert.cfg

# Get text styles
red=$(tput setaf 1)
yellow=$(tput setaf 3)
bold=$(tput bold)
underline=$(tput smul)
normal=$(tput sgr0)

# Make sure targets file exists, otherwise exit
if [ ! -f $PB_TRGTS ]; then
    echo "${red}ERROR${normal}: Push targets file '$PB_TRGTS' not found!"
    exit
fi

# Get microphone device ID from the name
HWDEVICE=$(arecord -l | grep "$MICROPHONE"  | awk '{ gsub(":",""); print $2}')

# Listen
while :
do
  # Figure out how loud the last segment of audio was
  AMPLITUDE=$(arecord -D plughw:$HWDEVICE,0 -d $SAMPLE_DURATION -f $FORMAT 2>/dev/null | sox -t .wav - -n stat 2>&1 | grep 'Maximum amplitude:'  | awk '{print $3}')

  # See if the volume is over the threshold variable
  COMPARE=$(echo "$AMPLITUDE > $THRESHOLD" | bc)

  if [ $COMPARE == 1 ]; then
    echo "${yellow}ALERT!${normal} Level $AMPLITUDE : $(date +"%a %b %d, %Y at %r")"
    push_notify
  else
    [ "$SHOW_LEVELS" == true ] && echo "No alert : Level $AMPLITUDE"
  fi
done
