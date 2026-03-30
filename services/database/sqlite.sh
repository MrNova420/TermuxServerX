#!/bin/bash
# TermuxServerX - SQLite Installer
set -e

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_sqlite() {
    log "Installing SQLite..."
    pkg update -y
    pkg install -y sqlite
    log "SQLite installed!"
}

install_sqlite
