#!/bin/bash
# Stream Commander - Start Engine
# This script starts the Python backend engine

cd "$(dirname "$0")/engine"

# Check if virtual environment exists
if [ ! -d "venv" ]; then
    echo "Creating virtual environment..."
    python3 -m venv venv
fi

# Activate virtual environment
source venv/bin/activate

# Install dependencies
pip install -r requirements.txt -q

# Start the engine
echo "Starting Stream Commander Engine..."
python3 main.py "$@"
