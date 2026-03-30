#!/data/data/com.termux/files/usr/bin/bash
# Valheim Server Manager
# Optimized for Termux/Android

set -e

SERVICE_NAME="valheim"
INSTALL_DIR="$HOME/TermuxServerX/data/valheim"
STEAMCMD_DIR="$HOME/steamcmd"
SERVER_NAME="${WORLD_NAME:-terrastation}"
SERVER_PASSWORD="${VALHEIM_PASSWORD:-}"
BACKUP_DIR="$HOME/TermuxServerX/backups/valheim"

check_dependencies() {
    local deps=("steamcmd" "screen")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo "[ERROR] Missing dependency: $dep"
            return 1
        fi
    done
}

install_valheim() {
    echo "[*] Installing Valheim server..."
    
    mkdir -p "$INSTALL_DIR"/{server,backups,logs}
    
    cd "$STEAMCMD_DIR"
    ./steamcmd.sh +login anonymous +force_install_dir "$INSTALL_DIR/server" +app_update 896660 validate +quit
    
    cat > "$INSTALL_DIR/start-server.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
export WORLD_NAME="${WORLD_NAME:-terrastation}"
export SERVER_NAME="${SERVER_NAME:-TermuxServer}"
export SERVER_PASSWORD="${SERVER_PASSWORD:-}"
export BACKUP_INTERVAL="${BACKUP_INTERVAL:-300}"

cd ~/TermuxServerX/data/valheim/server

screen -S valheim -m ./valheim_server.x86_64 -name "$SERVER_NAME" -port 2456 -world "$WORLD_NAME" -password "$SERVER_PASSWORD" -backups
EOF
    chmod +x "$INSTALL_DIR/start-server.sh"
    
    echo "[+] Valheim installed successfully!"
}

start_valheim() {
    if screen -list | grep -q "$SERVICE_NAME"; then
        echo "[*] Valheim is already running"
        return 0
    fi
    
    cd "$INSTALL_DIR"
    screen -dmS valheim ./start-server.sh
    echo "[+] Valheim server started"
}

stop_valheim() {
    screen -S valheim -X quit 2>/dev/null || true
    echo "[+] Valheim server stopped"
}

restart_valheim() {
    stop_valheim
    sleep 2
    start_valheim
}

backup_valheim() {
    mkdir -p "$BACKUP_DIR"
    local backup_name="valheim_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    tar -czf "$BACKUP_DIR/$backup_name" -C "$INSTALL_DIR" world server/worlds 2>/dev/null || true
    
    echo "[+] Backup created: $backup_name"
    
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete 2>/dev/null || true
}

status_valheim() {
    if screen -list | grep -q "$SERVICE_NAME"; then
        echo "[+] Valheim is RUNNING"
        screen -list | grep "$SERVICE_NAME"
    else
        echo "[-] Valheim is STOPPED"
    fi
}

case "$1" in
    install) install_valheim ;;
    start) start_valheim ;;
    stop) stop_valheim ;;
    restart) restart_valheim ;;
    backup) backup_valheim ;;
    status) status_valheim ;;
    *) echo "Usage: $0 {install|start|stop|restart|backup|status}" ;;
esac
