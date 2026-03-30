#!/bin/bash
# TermuxServerX - PostgreSQL Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/config.env" 2>/dev/null || true

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_postgresql() {
    log "Installing PostgreSQL..."
    
    pkg update -y
    pkg install -y postgresql
    
    mkdir -p "$TSX_DIR/data/postgresql"
    mkdir -p "$HOME/storage/shared/postgresql"
    mkdir -p "$TSX_DIR/logs/postgresql"
    
    # Initialize database
    if [ ! -d "$HOME/storage/shared/postgresql/data" ]; then
        initdb -D "$HOME/storage/shared/postgresql/data" 2>/dev/null || true
    fi
    
    log "PostgreSQL installed!"
    echo "Data: $HOME/storage/shared/postgresql/data"
}

start_postgresql() {
    pg_ctl -D "$HOME/storage/shared/postgresql/data" start 2>/dev/null || \
    postgres -D "$HOME/storage/shared/postgresql/data" &
    log "PostgreSQL started on port 5432"
}

stop_postgresql() {
    pg_ctl -D "$HOME/storage/shared/postgresql/data" stop 2>/dev/null || \
    pkill -f postgres
}

case "${1:-install}" in
    install) install_postgresql ;;
    start) start_postgresql ;;
    stop) stop_postgresql ;;
    *) echo "Usage: $0 {install|start|stop}" ;;
esac
