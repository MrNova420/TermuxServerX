#!/bin/bash
# TermuxServerX - Syncthing File Sync Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_syncthing() {
    log "Installing Syncthing..."
    
    pkg update -y
    pkg install -y wget
    
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64) ARCH="arm64" ;;
        x86_64|amd64) ARCH="amd64" ;;
        *) ARCH="arm" ;;
    esac
    
    VERSION="1.27.2"
    
    mkdir -p "$TSX_DIR/data/syncthing"
    
    wget -q -O "$TSX_DIR/data/syncthing/syncthing" \
        "https://github.com/syncthing/syncthing/releases/download/v${VERSION}/syncthing-linux-${ARCH}-v${VERSION}.tar.gz" 2>/dev/null || \
    wget -q -O "$TSX_DIR/data/syncthing/syncthing" \
        "https://github.com/syncthing/syncthing/releases/latest/download/syncthing-linux-${ARCH}.tar.gz"
    
    chmod +x "$TSX_DIR/data/syncthing/syncthing"
    
    mkdir -p "$HOME/storage/shared/sync"
    
    log "Syncthing installed!"
    echo "Run: cd $TSX_DIR/data/syncthing && ./syncthing"
    echo "Web UI: http://localhost:8384"
}

start_syncthing() {
    cd "$TSX_DIR/data/syncthing"
    nohup ./syncthing > "$TSX_DIR/logs/syncthing.log" 2>&1 &
    log "Syncthing started"
}

case "${1:-install}" in
    install) install_syncthing ;;
    start) start_syncthing ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
