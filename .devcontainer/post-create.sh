#!/bin/bash

# this runs at Codespace creation - not part of pre-build

echo "post-create start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-create start" >> "$HOME/status"

# add your commands here

echo "post-create complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-create complete" >> "$HOME/status"
