#!/bin/bash

# this runs each time the container starts

echo "post-start start"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-start start" >> "$HOME/status"

docker pull mcr.microsoft.com/vscode/devcontainers/dotnet
docker pull alpine

echo "post-start complete"
echo "$(date +'%Y-%m-%d %H:%M:%S')    post-start complete" >> "$HOME/status"
