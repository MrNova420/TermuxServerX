#!/bin/bash
# TermuxServerX - Outline Wiki (Team Knowledge Base)
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_outline() {
    log "Installing Outline Wiki..."
    
    pkg update -y
    pkg install -y nodejs npm postgresql redis
    
    mkdir -p "$TSX_DIR/data/outline"
    mkdir -p "$HOME/storage/shared/outline"
    
    cd "$TSX_DIR/data/outline"
    npm install -g outline-server
    
    log "Outline installed!"
    echo "Run: outline-server"
    echo "Web UI: http://localhost:3000"
}

case "${1:-install}" in
    install) install_outline ;;
    *) echo "Usage: $0 install" ;;
esac
