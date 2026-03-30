#!/bin/bash
# TermuxServerX - Netdata Installer
set -e

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_netdata() {
    log "Installing Netdata..."
    
    pkg update -y
    pkg install -y netdata || {
        log "Netdata not available in Termux repos."
        log "Alternative: Access system stats via Web UI dashboard."
    }
    
    log "Netdata setup initiated"
}

case "${1:-install}" in
    install) install_netdata ;;
    *) echo "Usage: $0 install" ;;
esac
