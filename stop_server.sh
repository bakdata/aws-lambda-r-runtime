#!/bin/bash

kill -9 `cat sam.pid`
rm sam.pid
echo "stopped sam server"
