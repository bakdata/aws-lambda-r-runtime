#!/bin/bash

if [ -f sam.pid ]; then
  ./stop_server.sh
fi
sam local start-lambda &
echo $! > sam.pid
sleep 10
echo "started sam server"
