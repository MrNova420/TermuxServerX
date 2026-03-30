#!/bin/bash
# TermuxServerX - Rclone Installer
set -e

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_rclone() {
    log "Installing Rclone..."
    pkg update -y
    pkg install -y rclone fuse
    log "Rclone installed!"
}

install_rclone
