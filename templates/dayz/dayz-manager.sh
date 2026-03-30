#!/data/data/com.termux/files/usr/bin/bash
# DayZ Server Manager
# Full connection info, configs, credentials

SERVICE_NAME="dayz"
INSTALL_DIR="$HOME/TermuxServerX/data/dayz"
STEAMCMD_DIR="$HOME/steamcmd"
BACKUP_DIR="$HOME/TermuxServerX/backups/dayz"

show_connection_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║            DayZ Server Connection Info                   ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "  Game: DayZ"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CONNECTION DETAILS                                      │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ IP Address:    $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_PUBLIC_IP')         │"
    echo "  │ Game Port:     2302                                    │"
    echo "  │ Query Port:    2303                                    │"
    echo "  │ Steam Port:    2304                                    │"
    echo "  │ RCON Port:     2305                                    │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ HOW TO CONNECT                                          │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ 1. Open DayZ                                           │"
    echo "  │ 2. Press ESC > PLAY > COMMUNITY                        │"
    echo "  │ 3. Click 'Favorites' tab                               │"
    echo "  │ 4. Click 'Add Server'                                  │"
    echo "  │ 5. Enter: $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_IP')                             │"
    echo "  │ 6. Port: 2302                                          │"
    echo "  │ 7. Server Password: $SERVER_PASSWORD                    │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CREDENTIALS                                             │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ Admin Password: $ADMIN_PASSWORD                          │"
    echo "  │ Server Password: $SERVER_PASSWORD                        │"
    echo "  │ RCON Password:  $RCON_PASSWORD                           │"
    echo "  │                                                        │"
    echo "  │ BECOME ADMIN IN-GAME:                                   │"
    echo "  │ 1. Press F1 or ~                                       │"
    echo "  │ 2. Type: #login [adminpassword]                         │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo "╚════════════════════════════════════════════════════════════╝"
}

show_config_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║            DayZ Configuration Guide                       ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    cat << 'CONFIGEOF'
  CONFIG FILES:
  ~/TermuxServerX/data/dayz/serverDZ.cfg - Main config
  ~/TermuxServerX/data/dayz/users.xml - Admin/players
  ~/TermuxServerX/data/dayz/storage_1/ - Persistence data

  KEY SETTINGS IN serverDZ.cfg:
  hostName="DayZ Server"
  password="SERVER_PASSWORD"
  passwordAdmin="ADMIN_PASSWORD"
  maxPlayers=60
  difficulty=1

  RCON COMMANDS:
  #login <password> - Authenticate
  #restart - Restart server
  #shutdown - Stop server
  #mission - Reload mission

  STEAM APP ID: 2233500 (DayZ Server)
CONFIGEOF
    echo "╚════════════════════════════════════════════════════════════╝"
}

show_secrets_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║            DayZ Secrets & Security                         ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo ""
    echo "  SECURE LOCATIONS:"
    echo "  ~/TermuxServerX/data/dayz/serverDZ.cfg - All passwords"
    echo "  ~/TermuxServerX/data/dayz/users.xml - Admin list"
    echo "  ~/TermuxServerX/data/dayz/storage_1/players/ - Player data"
    echo ""
    echo "  BACKUP LOCATION:"
    echo "  ~/TermuxServerX/backups/dayz/"
    echo ""
    echo "  ⚠️  SECURITY:"
    echo "  • Change passwordAdmin BEFORE first start"
    echo "  • Backup storage_1 folder regularly"
    echo "  • Server persistence files are critical"
    echo "  • Monitor logs for unauthorized access"
    echo ""
    echo "  TO ADD ADMIN:"
    echo "  1. Stop server"
    echo "  2. Edit users.xml"
    echo "  3. Add: <user name="PLAYER_NAME" auth="STEAM_ID"/>"
    echo "  4. Restart server"
    echo "╚════════════════════════════════════════════════════════════╝"
}

install_dayz() {
    mkdir -p "$INSTALL_DIR"/{server,backups}
    cd "$STEAMCMD_DIR"
    ./steamcmd.sh +login anonymous +force_install_dir "$INSTALL_DIR/server" +app_update 2233500 validate +quit
    echo "[+] DayZ installed"
}

start_dayz() {
    screen -dmS dayz "$INSTALL_DIR/server/startserver.sh"
    echo "[+] DayZ started"
}

stop_dayz() {
    screen -S dayz -X quit 2>/dev/null
    echo "[+] DayZ stopped"
}

backup_dayz() {
    mkdir -p "$BACKUP_DIR"
    tar -czf "$BACKUP_DIR/dayz_$(date +%Y%m%d_%H%M%S).tar.gz" \
        -C "$INSTALL_DIR" storage_1 2>/dev/null || true
    echo "[+] Backup created"
}

case "$1" in
    install) install_dayz ;;
    start) start_dayz ;;
    stop) stop_dayz ;;
    restart) stop_dayz; sleep 2; start_dayz ;;
    backup) backup_dayz ;;
    info) show_connection_info ;;
    config) show_config_info ;;
    secrets) show_secrets_info ;;
    *) echo "Usage: $0 {install|start|stop|restart|backup|info|config|secrets}" ;;
esac
