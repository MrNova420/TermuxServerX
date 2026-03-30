#!/bin/bash
# TermuxServerX - Git Installer
set -e

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_git() {
    log "Installing Git..."
    pkg update -y
    pkg install -y git
    git config --global user.email "user@termux.local"
    git config --global user.name "TermuxServerX User"
    git config --global core.editor "nano"
    git config --global init.defaultBranch main
    log "Git installed!"
}

install_git
