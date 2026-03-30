#!/bin/bash
# TermuxServerX - FileBrowser Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_filebrowser() {
    log "Installing FileBrowser..."
    
    pkg update -y
    pkg install -y wget
    
    ARCH=$(uname -m)
    case "$ARCH" in aarch64|arm64) ARCH="arm64" ;; x86_64|amd64) ARCH="amd64" ;; *) ARCH="armv7" ;; esac
    
    mkdir -p "$TSX_DIR/data/filebrowser"
    wget -q -O "$TSX_DIR/data/filebrowser/filebrowser" "https://github.com/filebrowser/filebrowser/releases/latest/download/linux-${ARCH}-filebrowser"
    chmod +x "$TSX_DIR/data/filebrowser/filebrowser"
    
    "$TSX_DIR/data/filebrowser/filebrowser" config init --address 0.0.0.0 --port 8081 \
        --database "$TSX_DIR/data/filebrowser/filebrowser.db" --root "$HOME/storage/shared" 2>/dev/null || true
    
    log "FileBrowser installed!"
    echo "Access: http://localhost:8081 | User: admin | Pass: admin"
}

start_filebrowser() {
    cd "$TSX_DIR/data/filebrowser"
    nohup ./filebrowser > "$TSX_DIR/logs/filebrowser.log" 2>&1 &
}

case "${1:-install}" in
    install) install_filebrowser ;;
    start) start_filebrowser ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
