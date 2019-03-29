#!/bin/bash

sam local start-lambda --parameter-overrides 'ParameterKey=RuntimeLayer,ParameterValue='"$1"' ParameterKey=RecommendedLayer,ParameterValue='"$2"' ParameterKey=AWSLayer,ParameterValue='"$3"'' &
echo $! > sam.pid
sleep 10
echo "started sam server"
