#!/data/data/com.termux/files/usr/bin/bash
# CS:GO/CS2 Server Manager
# Optimized for Termux/Android

set -e

SERVICE_NAME="csgo"
INSTALL_DIR="$HOME/TermuxServerX/data/csgo"
STEAMCMD_DIR="$HOME/steamcmd"
GAME_TYPE="${GAME_TYPE:-csgo}"
MAP="${MAP:-de_dust2}"
MAX_PLAYERS="${MAX_PLAYERS:-10}"
BACKUP_DIR="$HOME/TermuxServerX/backups/csgo"

check_dependencies() {
    local deps=("steamcmd" "screen")
    for dep in "${deps[@]}"; do
        if ! command -v "$dep" &>/dev/null; then
            echo "[ERROR] Missing dependency: $dep"
            return 1
        fi
    done
}

install_csgo() {
    echo "[*] Installing $GAME_TYPE server..."
    
    mkdir -p "$INSTALL_DIR"/{server,config,logs}
    
    local APP_ID="740"
    [[ "$GAME_TYPE" == "cs2" ]] && APP_ID="730"
    
    cd "$STEAMCMD_DIR"
    ./steamcmd.sh +login anonymous +force_install_dir "$INSTALL_DIR/server" +app_update "$APP_ID" validate +quit
    
    cp "$INSTALL_DIR/server/csgo/cfg/server.cfg" "$INSTALL_DIR/config/" 2>/dev/null || true
    
    cat > "$INSTALL_DIR/start-server.sh" << EOF
#!/data/data/com.termux/files/usr/bin/bash
cd $INSTALL_DIR/server/csgo

screen -S csgo ./srcds_run -game csgo -console -port 27015 +map $MAP +maxplayers $MAX_PLAYERS +sv_setsteamaccount "" -tickrate 64
EOF
    chmod +x "$INSTALL_DIR/start-server.sh"
    
    echo "[+] $GAME_TYPE server installed!"
}

start_csgo() {
    if screen -list | grep -q "$SERVICE_NAME"; then
        echo "[*] $GAME_TYPE is already running"
        return 0
    fi
    
    cd "$INSTALL_DIR"
    screen -dmS csgo ./start-server.sh
    echo "[+] $GAME_TYPE server started"
}

stop_csgo() {
    screen -S csgo -X quit 2>/dev/null || true
    echo "[+] $GAME_TYPE server stopped"
}

restart_csgo() {
    stop_csgo
    sleep 2
    start_csgo
}

status_csgo() {
    if screen -list | grep -q "$SERVICE_NAME"; then
        echo "[+] $GAME_TYPE is RUNNING"
        screen -list | grep "$SERVICE_NAME"
    else
        echo "[-] $GAME_TYPE is STOPPED"
    fi
}

case "$1" in
    install) install_csgo ;;
    start) start_csgo ;;
    stop) stop_csgo ;;
    restart) restart_csgo ;;
    status) status_csgo ;;
    *) echo "Usage: $0 {install|start|stop|restart|status}" ;;
esac
