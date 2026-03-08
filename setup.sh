#!/bin/bash
# Stream Commander - Initial Setup
# Run this script once to set up the development environment

set -e

cd "$(dirname "$0")"

echo "================================"
echo "Stream Commander Setup"
echo "================================"
echo

# Check for required tools
echo "Checking dependencies..."

if ! command -v python3 &> /dev/null; then
    echo "ERROR: Python 3 is required but not installed."
    exit 1
fi

if ! command -v node &> /dev/null; then
    echo "ERROR: Node.js is required but not installed."
    exit 1
fi

if ! command -v npm &> /dev/null; then
    echo "ERROR: npm is required but not installed."
    exit 1
fi

# Install Rust if not present
if ! command -v cargo &> /dev/null; then
    echo "Rust/Cargo not found. Installing via rustup..."
    curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y
    source "$HOME/.cargo/env"
    echo "Rust installed successfully."
else
    echo "Rust/Cargo found."
fi

echo "All dependencies found!"
echo

# Setup Python environment
echo "Setting up Python environment..."
cd engine
python3 -m venv venv
source venv/bin/activate
pip install -r requirements.txt
deactivate
cd ..

echo "Python environment ready."
echo

# Setup Node.js environment
echo "Setting up Node.js environment..."
cd apps/desktop
npm install
cd ../..

echo "Node.js environment ready."
echo

# Install Tauri CLI
echo "Installing Tauri CLI..."
cd apps/desktop
npx @tauri-apps/cli init --app-name "Stream Commander" --window-title "Stream Commander" --ci 2>/dev/null || true
cd ../..

# Create data directories
echo "Creating data directories..."
mkdir -p ~/Library/Application\ Support/StreamCommander/plugins

echo
echo "================================"
echo "Setup Complete!"
echo "================================"
echo
echo "To start development:"
echo "  ./start-dev.sh"
echo
echo "To start only the backend:"
echo "  ./start-engine.sh"
echo
echo "To build the desktop app:"
echo "  cd apps/desktop && npm run tauri dev"
echo
echo "To open in Xcode:"
echo "  open StreamCommander.xcodeproj"
echo
