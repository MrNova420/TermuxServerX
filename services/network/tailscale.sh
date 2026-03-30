#!/bin/bash
# TermuxServerX - Tailscale VPN Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_tailscale() {
    log "Installing Tailscale..."
    
    pkg update -y
    pkg install -y wget gnupg
    
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64) ARCH="arm64" ;;
        x86_64|amd64) ARCH="amd64" ;;
        *) ARCH="arm" ;;
    esac
    
    # Download Tailscale static binary
    local VERSION="1.58.2"
    wget -q -O "$PREFIX/bin/tailscale" \
        "https://pkgs.tailscale.com/stable/tailscale_${VERSION}_${ARCH}.tgz" 2>/dev/null || \
    curl -fsSL "https://pkgs.tailscale.com/stable/tailscale_linux_${ARCH}.tgz" | tar -xz -C /tmp
    
    tar -xzf "/tmp/tailscale_${VERSION}_${ARCH}.tgz" -C "$PREFIX" 2>/dev/null || \
    tar -xzf "/tmp/tailscale_linux_${ARCH}.tgz" -C "$PREFIX" 2>/dev/null || true
    
    chmod +x "$PREFIX/bin/tailscaled" "$PREFIX/bin/tailscale"
    
    mkdir -p "$TSX_DIR/logs/vpn"
    
    log "Tailscale installed!"
    echo ""
    echo "To connect:"
    echo "1. Run: tailscaled &"
    echo "2. Then: tailscale up --accept-dns"
    echo "3. Get auth key from: https://login.tailscale.com/admin/settings/keys"
}

start_tailscaled() {
    nohup tailscaled --tun=tsipcvpn --state=ts state &>/dev/null &
    log "Tailscale daemon started"
}

stop_tailscaled() {
    pkill tailscaled 2>/dev/null || true
}

case "${1:-install}" in
    install) install_tailscale ;;
    start) start_tailscaled ;;
    stop) stop_tailscaled ;;
    *) echo "Usage: $0 {install|start|stop}" ;;
esac
