#!/bin/bash

PB_API=""

PB_TITLE="Alarm Triggered!"
PB_MSG="The alarm was set off on $(date +"%a %b %d, %Y at%r")"

MICROPHONE='QuickCam Pro 9000'
SAMPLE_DURATION=2 # seconds
FORMAT='CD'
THRESHOLD=0.9

HWDEVICE=$(arecord -l | grep "$MICROPHONE"  | awk '{ gsub(":",""); print $2}')

while :
do
  AMPLITUDE=$(arecord -D plughw:$HWDEVICE,0 -d $SAMPLE_DURATION -f $FORMAT 2>/dev/null | sox -t .wav - -n stat 2>&1 | grep 'Maximum amplitude:'  | awk '{print $3}')

  # Echo the Amplitude if --verbose is set

  COMPARE=$(echo "$AMPLITUDE > $THRESHOLD" | bc)

  if [ $COMPARE -eq 1 ]; then
    echo "Audio Detected! : Level $AMPLITUDE"
    curl -u $PB_API: https://api.pushbullet.com/v2/pushes -d type=note -d title="$PB_TITLE" -d body="$PB_MSG"
  else
    echo "No audio : Level $AMPLITUDE"
  fi
done
