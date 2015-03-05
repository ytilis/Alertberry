#!/bin/bash

function parse_json()
{
    echo $1 | sed -e 's/[{}]/''/g' | awk -F=':' -v RS=',' "\$1~/\"$2\"/ {print}" | sed -e "s/\"$2\"://" | tr -d "\n\t" | sed -e 's/\\"/"/g' | sed -e 's/\\\\/\\/g' | sed -e 's/^[ \t]*//g' | sed -e 's/^"//'  -e 's/"$//'
}

source alert.cfg

HWDEVICE=$(arecord -l | grep "$MICROPHONE"  | awk '{ gsub(":",""); print $2}')

while :
do
  AMPLITUDE=$(arecord -D plughw:$HWDEVICE,0 -d $SAMPLE_DURATION -f $FORMAT 2>/dev/null | sox -t .wav - -n stat 2>&1 | grep 'Maximum amplitude:'  | awk '{print $3}')

  # Echo the Amplitude if --verbose is set

  COMPARE=$(echo "$AMPLITUDE > $THRESHOLD" | bc)

  if [ $COMPARE -eq 1 ]; then
    echo "Audio Detected! : Level $AMPLITUDE"

    IFS=:
    while read name token
    do
      OUT=$(curl --silent --show-error --write-out '\n%{http_code}' -u $token: https://api.pushbullet.com/v2/pushes -d type=note -d title="$PB_TITLE" -d body="$PB_MSG") 2>/dev/null

     # parse_json '{"username":"john doe","email":"john@doe.com"}' email

     # get exit code
      RET=$?

      if [[ $RET -ne 0 ]] ; then
        # if error exit code, print exit code
        echo "Error $RET"

        # print HTTP error
        echo "HTTP Error: $(echo "$OUT" | tail -n1 )"
      else
        # otherwise print last line of output, i.e. HTTP status code
        echo "Success, HTTP status is:"
        echo "$OUT" | tail -n1

        # and print all but the last line, i.e. the regular response
        echo "Response is:"
        echo "$OUT" | head -n-1
      fi

    done < targets.txt
  else
    echo "No audio : Level $AMPLITUDE"
  fi
done
