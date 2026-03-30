#!/bin/bash
# TermuxServerX - WireGuard VPN Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_wireguard() {
    log "Installing WireGuard..."
    
    pkg update -y
    pkg install -y wireguard-tools
    
    mkdir -p "$TSX_DIR/data/wireguard"
    mkdir -p "$HOME/storage/shared/wireguard"
    mkdir -p "$TSX_DIR/logs/vpn"
    
    log "WireGuard installed!"
    echo ""
    echo "WireGuard config location: $HOME/storage/shared/wireguard/"
    echo ""
    echo "To setup:"
    echo "1. Generate keys: wg genkey | tee privatekey | wg pubkey > publickey"
    echo "2. Create config in $HOME/storage/shared/wireguard/wg0.conf"
    echo "3. Run: wg-quick up wg0"
}

setup_config() {
    local server_endpoint=$1
    local server_port=${2:-51820}
    local client_ip=$3
    local private_key=$4
    local public_key=$5
    local preshared_key=${6:-""}
    
    cat > "$HOME/storage/shared/wireguard/wg0.conf" << EOF
[Interface]
PrivateKey = $private_key
Address = $client_ip/24
DNS = 1.1.1.1

[Peer]
PublicKey = $public_key
PresharedKey = $preshared_key
Endpoint = $server_endpoint:$server_port
AllowedIPs = 0.0.0.0/0
PersistentKeepalive = 25
EOF
    
    log "Config created at $HOME/storage/shared/wireguard/wg0.conf"
}

start_wireguard() {
    if [ -f "$HOME/storage/shared/wireguard/wg0.conf" ]; then
        wg-quick up wg0 && log "WireGuard started" || log "Failed to start WireGuard"
    else
        log "No config found. Create wg0.conf first."
    fi
}

stop_wireguard() {
    wg-quick down wg0 2>/dev/null && log "WireGuard stopped" || true
}

case "${1:-install}" in
    install) install_wireguard ;;
    setup) setup_config "$2" "$3" "$4" "$5" "$6" "$7" ;;
    start) start_wireguard ;;
    stop) stop_wireguard ;;
    *) echo "Usage: $0 {install|setup|start|stop}" ;;
esac
