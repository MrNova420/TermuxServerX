#!/data/data/com.termux/files/usr/bin/bash
# Rust Server Manager
# Optimized for Termux/Android

set -e

SERVICE_NAME="rust"
INSTALL_DIR="$HOME/TermuxServerX/data/rust"
STEAMCMD_DIR="$HOME/steamcmd"
BACKUP_DIR="$HOME/TermuxServerX/backups/rust"

check_dependencies() {
    local deps=("steamcmd" "screen")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo "[ERROR] Missing dependency: $dep"
            return 1
        fi
    done
}

install_rust() {
    echo "[*] Installing Rust server..."
    
    mkdir -p "$INSTALL_DIR"/{server,config,backups,logs}
    
    cd "$STEAMCMD_DIR"
    ./steamcmd.sh +login anonymous +force_install_dir "$INSTALL_DIR/server" +app_update 258550 validate +quit
    
    cat > "$INSTALL_DIR/start-server.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
cd ~/TermuxServerX/data/rust/server

MEMORY=${MEMORY:-2048}

./RustDedicated -batchmode +server.ip 0.0.0.0 +server.port 28015 +rcon.ip 0.0.0.0 +rcon.port 28016 +rcon.password "${RCON_PASSWORD:-CHANGE_ME}" +server.level "Procedural Map" +server.maxplayers 50 +server.seed 12345 +server.worldsize 4000 +server.saveinterval 300 -logFile "server.log"
EOF
    chmod +x "$INSTALL_DIR/start-server.sh"
    
    echo "[+] Rust server installed!"
}

start_rust() {
    if screen -list | grep -q "$SERVICE_NAME"; then
        echo "[*] Rust is already running"
        return 0
    fi
    
    cd "$INSTALL_DIR"
    screen -dmS rust ./start-server.sh
    echo "[+] Rust server started"
}

stop_rust() {
    screen -S rust -X quit 2>/dev/null || true
    echo "[+] Rust server stopped"
}

restart_rust() {
    stop_rust
    sleep 2
    start_rust
}

backup_rust() {
    mkdir -p "$BACKUP_DIR"
    local backup_name="rust_backup_$(date +%Y%m%d_%H%M%S).tar.gz"
    
    tar -czf "$BACKUP_DIR/$backup_name" -C "$INSTALL_DIR/server" server/*.map 2>/dev/null || true
    
    echo "[+] Backup created: $backup_name"
    
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +7 -delete 2>/dev/null || true
}

status_rust() {
    if screen -list | grep -q "$SERVICE_NAME"; then
        echo "[+] Rust is RUNNING"
        screen -list | grep "$SERVICE_NAME"
    else
        echo "[-] Rust is STOPPED"
    fi
}

case "$1" in
    install) install_rust ;;
    start) start_rust ;;
    stop) stop_rust ;;
    restart) restart_rust ;;
    backup) backup_rust ;;
    status) status_rust ;;
    *) echo "Usage: $0 {install|start|stop|restart|backup|status}" ;;
esac
