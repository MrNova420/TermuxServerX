#!/bin/bash
# TermuxServerX - ngrok Tunnel Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_ngrok() {
    log "Installing ngrok..."
    
    pkg update -y
    pkg install -y wget unzip
    
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64) ARCH="arm64" ;;
        x86_64|amd64) ARCH="amd64" ;;
        *) ARCH="arm" ;;
    esac
    
    wget -q -O "$PREFIX/bin/ngrok" \
        "https://bin.equinox.io/c/bNyj1mQVY4c/ngrok-v3-stable-linux-${ARCH}.zip"
    
    unzip -q "$PREFIX/bin/ngrok" -o "$PREFIX/bin/"
    chmod +x "$PREFIX/bin/ngrok"
    
    mkdir -p "$TSX_DIR/logs/tunnel"
    
    log "ngrok installed!"
    echo ""
    echo "To use:"
    echo "1. Sign up at https://ngrok.com"
    echo "2. Get your authtoken from https://dashboard.ngrok.com/auth"
    echo "3. Run: ngrok config add-authtoken YOUR_TOKEN"
    echo "4. Run: ngrok http 8080"
}

quick_tunnel() {
    log "Starting ngrok tunnel to port 8080..."
    ngrok http 8080
}

case "${1:-install}" in
    install) install_ngrok ;;
    tunnel) quick_tunnel ;;
    *) echo "Usage: $0 {install|tunnel}" ;;
esac
