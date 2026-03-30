#!/bin/bash
# TermuxServerX - Ghost Blog/CMS Platform
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_ghost() {
    log "Installing Ghost (Blog/CMS)..."
    
    pkg update -y
    pkg install -y nodejs npm sqlite
    
    mkdir -p "$TSX_DIR/data/ghost"
    mkdir -p "$HOME/storage/shared/ghost"
    mkdir -p "$TSX_DIR/logs/ghost"
    
    cd "$TSX_DIR/data/ghost"
    npm install ghost-cli -g
    
    log "Ghost CLI installed!"
    echo ""
    echo "To install Ghost:"
    echo "  mkdir -p $HOME/storage/shared/ghost"
    echo "  cd $HOME/storage/shared/ghost"
    echo "  ghost install local"
}

start_ghost() {
    cd "$HOME/storage/shared/ghost"
    ghost start
    log "Ghost started"
}

case "${1:-install}" in
    install) install_ghost ;;
    start) start_ghost ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
