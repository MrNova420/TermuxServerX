#!/bin/bash
# TermuxServerX - Redis Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

install_redis() {
    log "Installing Redis..."
    pkg update -y
    pkg install -y redis
    mkdir -p "$TSX_DIR/logs/redis"
    log "Redis installed!"
}

start_redis() {
    log "Starting Redis..."
    redis-server --daemonize yes --logfile "$TSX_DIR/logs/redis/redis.log"
}

case "${1:-install}" in
    install) install_redis ;;
    start) start_redis ;;
    *) echo "Usage: $0 {install|start}" ;;
esac
