#!/bin/bash
state_file="/home/morgan/.cache/waybar-recording"

if [ -f "$state_file" ]; then
  printf '{"text":"⦿","class":"recording"}\n'
else
  printf '{"text":"","class":"idle"}\n'
fi
