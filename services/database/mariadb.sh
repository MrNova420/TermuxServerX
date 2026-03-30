#!/bin/bash
# TermuxServerX - MariaDB Installer
set -e

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/config.env" 2>/dev/null || true

GREEN='\033[0;32m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }

DB_DIR="$TSX_DIR/data/mariadb"
DB_RAM="${TSX_DB_RAM:-256M}"

install_mariadb() {
    log "Installing MariaDB..."
    pkg update -y
    pkg install -y mariadb
    
    mkdir -p "$DB_DIR"
    mkdir -p "$TSX_DIR/logs/mariadb"
    
    cat > "$PREFIX/etc/my.cnf.d/custom.cnf" << EOF
[mysqld]
datadir=$DB_DIR
tmpdir=/tmp
socket=/tmp/mysql.sock
pid-file=$DB_DIR/mysql.pid
max_connections=100
key_buffer_size=32M
max_allowed_packet=64M
innodb_buffer_pool_size=${DB_RAM}
innodb_log_file_size=16M
innodb_flush_log_at_trx_commit=2
sync_binlog=0
EOF
    
    [ -f "$DB_DIR/mysql/user.MYD" ] || mysql_install_db --datadir="$DB_DIR" --auth-root-authentication-mode=normal 2>/dev/null || true
    
    log "MariaDB installed!"
}

start_mariadb() {
    log "Starting MariaDB..."
    mysqld --datadir="$DB_DIR" --socket=/tmp/mysql.sock &
    sleep 3
    log "MariaDB started on port 3306"
}

stop_mariadb() {
    mysqladmin shutdown 2>/dev/null || pkill -f mysqld
}

case "${1:-install}" in
    install) install_mariadb ;;
    start) start_mariadb ;;
    stop) stop_mariadb ;;
    *) echo "Usage: $0 {install|start|stop}" ;;
esac
