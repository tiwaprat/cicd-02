#!/bin/sh

# Kill old instance if running
PID=$(lsof -ti:9090)
if [ -n "$PID" ]; then
    kill -9 $PID
    echo "Killed old app running on port 9090"
fi

# Start new instance in background and detach
nohup java -jar /var/lib/jenkins/workspace/StudentApp/target/studentapp-1.0.0.jar --server.port=9090 &
disown
