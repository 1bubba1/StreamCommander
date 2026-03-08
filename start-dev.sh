#!/bin/bash
# Stream Commander - Development Mode
# Starts engine + Tauri desktop app in a closed loop
# Handles graceful shutdown on exit

cd "$(dirname "$0")"

ENGINE_PID=""
FRONTEND_PID=""
TOKEN_FILE="$HOME/Library/Application Support/StreamCommander/.session_token"

cleanup() {
    echo ""
    echo "Shutting down Stream Commander..."

    curl -s -X POST http://127.0.0.1:9000/shutdown \
        -H "X-SC-Token: $(cat "$TOKEN_FILE" 2>/dev/null)" 2>/dev/null

    sleep 1

    if [ -n "$FRONTEND_PID" ] && kill -0 "$FRONTEND_PID" 2>/dev/null; then
        echo "Stopping frontend..."
        kill -TERM "$FRONTEND_PID" 2>/dev/null
        wait "$FRONTEND_PID" 2>/dev/null
    fi

    if [ -n "$ENGINE_PID" ] && kill -0 "$ENGINE_PID" 2>/dev/null; then
        echo "Stopping engine..."
        kill -TERM "$ENGINE_PID" 2>/dev/null

        for i in 1 2 3 4 5; do
            if ! kill -0 "$ENGINE_PID" 2>/dev/null; then
                break
            fi
            sleep 1
        done

        if kill -0 "$ENGINE_PID" 2>/dev/null; then
            echo "Engine didn't stop in time, forcing..."
            kill -9 "$ENGINE_PID" 2>/dev/null
        fi
    fi

    lsof -ti:9000 | xargs kill -TERM 2>/dev/null
    lsof -ti:1420 | xargs kill -TERM 2>/dev/null

    echo "Stream Commander stopped."
    exit 0
}

trap cleanup EXIT INT TERM HUP

# Load Rust/Cargo
if [ -f "$HOME/.cargo/env" ]; then
    source "$HOME/.cargo/env"
fi

if ! command -v cargo &> /dev/null; then
    echo "ERROR: Rust/Cargo is required for Stream Commander."
    echo "Run ./setup.sh to install."
    exit 1
fi

# Start engine in background
echo "Starting backend engine..."
./start-engine.sh &
ENGINE_PID=$!

# Wait for engine to be ready
echo "Waiting for engine..."
for i in 1 2 3 4 5 6 7 8 9 10; do
    if curl -s http://127.0.0.1:9000/health > /dev/null 2>&1; then
        echo "Engine ready."
        break
    fi
    sleep 1
done

# Start Tauri desktop app
echo "Starting Stream Commander desktop..."
cd apps/desktop
npm install --silent
npm run tauri dev &
FRONTEND_PID=$!
wait $FRONTEND_PID
