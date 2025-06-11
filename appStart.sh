#!/bin/sh
cd "$(dirname "$0")" || exit 1

# Prevent Jenkins from killing the process
export BUILD_ID=dontKillMe

# Try to get PID of process using port 9090; suppress non-zero exit with '|| true'
PID=$(lsof -ti:9090 || true)

if [ -n "$PID" ]; then
    echo "Process found on port 9090 with PID: $PID"
      kill -9 $PID
      echo "Killed process $PID using port 9090"
else
    echo  "No process is currently using port 9090"
fi

# Start new instance in background and detach
nohup java -jar target/studentapp-1.0.0.jar --server.port=9090 &
disown

