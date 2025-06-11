#!/bin/sh
cd "$(dirname "$0")" || exit 1

# Prevent Jenkins from killing the process
export BUILD_ID=dontKillMe



# Start new instance in background and detach
nohup java -jar target/studentapp-1.0.0.jar --server.port=9090 &
disown

