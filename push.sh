#!/bin/bash

# Pushbullet API Key
API=""

TITLE="Alarm Triggered!"
MSG="The alarm was set off on $(date +"%a %b %d, %Y at%r")"

curl -u $API: https://api.pushbullet.com/v2/pushes -d type=note -d title="$TITLE" -d body="$MSG"
