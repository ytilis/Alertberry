#!/bin/bash

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
    ./push.sh
  else
    echo "No audio : Level $AMPLITUDE"
  fi
done
