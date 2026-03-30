#!/bin/bash
# TermuxServerX - Immich Photo Management (Most Popular 2026)
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_immich() {
    log "Installing Immich (Photo Management)..."
    
    pkg update -y
    pkg install -y nodejs npm git
    
    mkdir -p "$TSX_DIR/data/immich"
    mkdir -p "$HOME/storage/shared/photos"
    mkdir -p "$TSX_DIR/logs/immich"
    
    cd "$TSX_DIR/data/immich"
    
    npm install -g immich
    
    log "Immich installed!"
    echo ""
    echo "Immich requires PostgreSQL and Redis"
    echo "Run: immich-server"
    echo "Web UI: http://localhost:2283"
    echo "Photos folder: $HOME/storage/shared/photos"
}

case "${1:-install}" in
    install) install_immich ;;
    *) echo "Usage: $0 install" ;;
esac
