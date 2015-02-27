#!/bin/bash

MICROPHONE='QuickCam Pro 9000'
HWDEVICE=$(arecord -l | grep "$MICROPHONE"  | awk '{ gsub(":",""); print $2}')
SAMPLE_DURATION=5 # seconds
FORMAT='CD'       # this is the format that my USB microphone generates
THRESHOLD=0.9

while :
do
  AMPLITUDE=$(arecord -D plughw:$HWDEVICE,0 -d $SAMPLE_DURATION -f $FORMAT 2>/dev/null | sox -t .wav - -n stat 2>&1 | grep 'Maximum amplitude:'  | awk '{print $3}')

  # Echo the Amplitude if --verbose is set
  # echo $AMPLITUDE

  COMPARE=$(echo "$AMPLITUDE > $THRESHOLD" | bc)

  if [ $COMPARE -eq 1 ]; then
    echo "Hit Threshold!"
    # ./push.sh
  else
    echo "No audio"
  fi
done