#!/bin/bash
# TermuxServerX - Python Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_python() {
    log "Installing Python..."
    pkg update -y
    pkg install -y python python-pip
    pip install --upgrade pip
    pip install flask psutil bcrypt requests cryptography distro schedule flask-cors uvicorn gunicorn
    log "Python installed!"
}

case "${1:-install}" in
    install) install_python ;;
    *) echo "Usage: $0 install" ;;
esac
