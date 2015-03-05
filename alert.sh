#!/bin/bash

function parse_json() {
  # save current IFS
  OLDIFS=$IFS

  IFS=' '
  echo $1 | sed -e 's/[{}]/''/g' | awk -F=':' -v RS=',' "\$1~/\"$2\"/ {print}" | sed -e "s/\"$2\"://" | tr -d "\n\t" | sed -e 's/\\"/"/g' | sed -e 's/\\\\/\\/g' | sed -e 's/^[ \t]*//g' | sed -e 's/^"//'  -e 's/"$//'

  # reset the IFS
  IFS=$OLDIFS
}

function push_notify() {
  IFS=:
  # Get the colon delimited list of people to notify
  while read NAME TOKEN
  do
    # Call Pushbullet
    OUT=$(curl --silent --show-error --write-out '\n%{http_code}' -u $TOKEN: https://api.pushbullet.com/v2/pushes -d type=note -d title="$PB_TITLE" -d body="$PB_MSG") 2>/dev/null

    # Get exit code
    RET=$?

    if [[ $RET -ne 0 ]] ; then
      # If error exit code, print exit code
      echo "Error $RET"

      # Print HTTP error
      echo "HTTP Error: $(echo "$OUT" | tail -n1 )"
    else
      STATUS=$(echo "$OUT" | tail -n1)    # HTTP Status
      RESPONSE=$(echo "$OUT" | head -n-1) # HTTP Body

      if [[ $STATUS -eq '200' ]] ; then
        # Success
        echo "$NAME has been alerted"
      else
        # Failure
        MESSAGE=$(parse_json "$RESPONSE" message)
        echo "Error alerting $NAME: $STATUS - $MESSAGE"
      fi
    fi

  done < targets.txt
}

# Import configs
source alert.cfg

# Get microphone device ID from the name
HWDEVICE=$(arecord -l | grep "$MICROPHONE"  | awk '{ gsub(":",""); print $2}')

# Listen
while :
do
  # Figure out how loud the last segment of audio was
  AMPLITUDE=$(arecord -D plughw:$HWDEVICE,0 -d $SAMPLE_DURATION -f $FORMAT 2>/dev/null | sox -t .wav - -n stat 2>&1 | grep 'Maximum amplitude:'  | awk '{print $3}')

  # Echo the Amplitude if --verbose is set

  # See if the volume is over the threshold variable
  COMPARE=$(echo "$AMPLITUDE > $THRESHOLD" | bc)

  if [ $COMPARE -eq 1 ]; then
    echo "Audio Detected! : Level $AMPLITUDE : $(date +"%a %b %d, %Y at %r")"
    push_notify
  else
    echo "No audio : Level $AMPLITUDE"
  fi
done
