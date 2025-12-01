#!/bin/bash

state_file="/home/morgan/.cache/waybar-recording"
out="/home/morgan/Videos/recording-$(date +%s).mp4"

# if recording -> stop
if pgrep -x wf-recorder > /dev/null; then
  pkill -x wf-recorder
  rm -f "$state_file"
  exit 0
fi

# start recording
mkdir -p /home/morgan/.cache
touch "$state_file"

wf-recorder \
  -o DP-1 \
  -r 60 \
  -c libx264 \
  -p preset=superfast \
  -p crf=22 \
  -p profile=high \
  -p level=5.2 \
  -f "$out" >/dev/null 2>&1 &
