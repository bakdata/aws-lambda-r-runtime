#!/bin/bash

set -euo pipefail

./start_server.sh
python -m unittest discover
./stop_server.sh
