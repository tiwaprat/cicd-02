#!/bin/sh
nohup java -jar /var/lib/jenkins/workspace/StudentApp/target/studentapp-1.0.0.jar --server.port=9090 & disown
