#!/data/data/com.termux/files/usr/bin/bash
# Palworld Server Manager
# Optimized for Termux/Android

set -e

SERVICE_NAME="palworld"
INSTALL_DIR="$HOME/TermuxServerX/data/palworld"
STEAMCMD_DIR="$HOME/steamcmd"
BACKUP_DIR="$HOME/TermuxServerX/backups/palworld"
SERVER_PORT="${SERVER_PORT:-8211}"

check_dependencies() {
    local deps=("steamcmd" "screen")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo "[ERROR] Missing dependency: $dep"
            return 1
        fi
    done
}

install_palworld() {
    echo "[*] Installing Palworld server..."
    
    mkdir -p "$INSTALL_DIR"/{server,backups,logs}
    
    cd "$STEAMCMD_DIR"
    ./steamcmd.sh +login anonymous +force_install_dir "$INSTALL_DIR/server" +app_update 2394010 validate +quit
    
    cat > "$INSTALL_DIR/start-server.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
export SERVER_PORT=${SERVER_PORT:-8211}
export ADMIN_PASSWORD=${ADMIN_PASSWORD:-}
export SERVER_PASSWORD=${SERVER_PASSWORD:-}

cd ~/TermuxServerX/data/palworld/server/Pal/Bin/Linux
./PalServer.sh -port=$SERVER_PORT -adminpassword=$ADMIN_PASSWORD
EOF
    chmod +x "$INSTALL_DIR/start-server.sh"
    
    echo "[+] Palworld installed successfully!"
}

start_palworld() {
    if screen -list | grep -q "$SERVICE_NAME"; then
        echo "[*] Palworld is already running"
        return 0
    fi
    
    cd "$INSTALL_DIR"
    screen -dmS palworld ./start-server.sh
    echo "[+] Palworld server started"
}

stop_palworld() {
    screen -S palworld -X quit 2>/dev/null || true
    echo "[+] Palworld server stopped"
}

restart_palworld() {
    stop_palworld
    sleep 2
    start_palworld
}

backup_palworld() {
    mkdir -p "$BACKUP_DIR"
    local backup_name="palworld_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    tar -czf "$BACKUP_DIR/$backup_name" -C "$INSTALL_DIR/server/Pal/Saved" save 2>/dev/null || true
    
    echo "[+] Backup created: $backup_name"
    
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete 2>/dev/null || true
}

status_palworld() {
    if screen -list | grep -q "$SERVICE_NAME"; then
        echo "[+] Palworld is RUNNING"
        screen -list | grep "$SERVICE_NAME"
    else
        echo "[-] Palworld is STOPPED"
    fi
}

case "$1" in
    install) install_palworld ;;
    start) start_palworld ;;
    stop) stop_palworld ;;
    restart) restart_palworld ;;
    backup) backup_palworld ;;
    status) status_palworld ;;
    *) echo "Usage: $0 {install|start|stop|restart|backup|status}" ;;
esac
