#!/bin/bash
# TermuxServerX - Node.js Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_node() {
    log "Installing Node.js..."
    pkg update -y
    pkg install -y nodejs npm
    
    npm config set prefix "$PREFIX"
    npm update -g npm
    npm install -g pm2
    
    log "Node.js installed!"
    echo "Node: $(node -v)" && echo "NPM: $(npm -v)"
}

case "${1:-install}" in
    install) install_node ;;
    *) echo "Usage: $0 install" ;;
esac
