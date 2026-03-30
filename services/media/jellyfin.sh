#!/bin/bash
# TermuxServerX - Jellyfin Media Server Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; }

install_jellyfin() {
    log "Installing Jellyfin..."
    
    pkg update -y
    pkg install -y wget unzip openjdk-17-headless
    
    mkdir -p "$TSX_DIR/data/jellyfin"
    mkdir -p "$HOME/storage/shared/media"
    
    log "Jellyfin data directory created"
    log "Note: Full Jellyfin server requires more setup. Download from: https://jellyfin.org/downloads/android/"
    
    log "Jellyfin setup initiated!"
}

case "${1:-install}" in
    install) install_jellyfin ;;
    *) echo "Usage: $0 install" ;;
esac
