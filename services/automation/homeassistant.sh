#!/bin/bash
# TermuxServerX - Home Assistant Installer (Home Automation)
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_homeassistant() {
    log "Installing Home Assistant..."
    
    pkg update -y
    pkg install -y python git curl
    
    mkdir -p "$TSX_DIR/data/homeassistant"
    cd "$TSX_DIR/data/homeassistant"
    
    python -m venv .
    ./bin/pip install homeassistant
    
    mkdir -p "$HOME/storage/shared/homeassistant"
    
    log "Home Assistant installed!"
    echo "Run: cd $TSX_DIR/data/homeassistant && ./bin/hass"
    echo "Web UI: http://localhost:8123"
}

start_homeassistant() {
    cd "$TSX_DIR/data/homeassistant"
    nohup ./bin/hass --config "$HOME/storage/shared/homeassistant" > "$TSX_DIR/logs/homeassistant.log" 2>&1 &
    log "Home Assistant started on port 8123"
}

case "${1:-install}" in
    install) install_homeassistant ;;
    start) start_homeassistant ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
