#!/data/data/com.termux/files/usr/bin/bash
# ARK: Survival Evolved Server Manager
# Optimized for Termux/Android

set -e

SERVICE_NAME="ark"
INSTALL_DIR="$HOME/TermuxServerX/data/ark"
STEAMCMD_DIR="$HOME/steamcmd"
BACKUP_DIR="$HOME/TermuxServerX/backups/ark"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

log() { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }

show_connection_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           ARK Server Connection Info                     ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "  Game: ARK: Survival Evolved"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CONNECTION DETAILS                                      │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ IP Address:    $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_PUBLIC_IP')         │"
    echo "  │ Query Port:    27015                                   │"
    echo "  │ Game Port:     7778                                    │"
    echo "  │ RCON Port:     27020                                    │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ HOW TO CONNECT                                          │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ 1. Open ARK: Survival Evolved                          │"
    echo "  │ 2. Press TAB or click 'Join ARK'                       │"
    echo "  │ 3. Click 'Search LAN' or 'Enter IP Manually'          │"
    echo "  │ 4. Enter: YOUR_IP:7778                                 │"
    echo "  │ 5. Server Password: $SERVER_PASSWORD                   │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CREDENTIALS (Store Securely!)                          │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ Server Admin Password: $ADMIN_PASSWORD                  │"
    echo "  │ Server Password:        $SERVER_PASSWORD                │"
    echo "  │ RCON Password:          $RCON_PASSWORD                   │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo "╚════════════════════════════════════════════════════════════╝"
}

show_config_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║              ARK Server Configuration Guide                 ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    cat << 'CONFIGEOF'
  GAME.INI SETTINGS LOCATION:
  ~/TermuxServerX/data/ark/ShooterGame/Saved/Config/LinuxServer/Game.ini

  KEY CONFIGURATIONS:
  
  [/script/shootergame.shootergamemode]
  MaxPlayers=10
  ProximityChat=False
  AllowThirdPerson=False
  AlwaysNotifyPlayerLeft=False
  AutoSaveFrequencyMinutes=15
  MaxStructuresInRange=100

  [ServerSettings]
  DifficultyOffset=0.200000
  MaxTamingSpeed=2.000000
  HarvestAmountMultiplier=2.000000
  XPMultiplier=2.000000
  TamingSpeedMultiplier=2.000000

  MOD SUPPORT:
  Workshop Mod IDs go in:
  ~/TermuxServerX/data/ark/arkserver_GameUserSettings.ini
  ActiveMods=123456789,987654321

  IMPORTANT FILES:
  • Game.ini - Game mode settings
  • GameUserSettings.ini - Server settings, passwords
  • ShooterGame/Binaries/Linux/ArkServer - Binary
  • ShooterGame/Saved - Saves and profiles
CONFIGEOF
    echo "╚════════════════════════════════════════════════════════════╝"
}

show_secrets_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║           ARK Server Secrets & Credentials                 ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo ""
    echo "  LOCATIONS:"
    echo "  • Passwords: ~/TermuxServerX/data/ark/ShooterGame/Saved/Config/LinuxServer/GameUserSettings.ini"
    echo "  • Logs: ~/TermuxServerX/data/ark/ShooterGame/Saved/Logs/"
    echo ""
    echo "  ⚠️  SECURITY NOTES:"
    echo "  • Never share admin password publicly"
    echo "  • Change default passwords immediately"
    echo "  • Use RCON only over trusted networks"
    echo "  • Regular backups prevent data loss"
    echo ""
    echo "  BACKUP FILES:"
    echo "  ~/TermuxServerX/backups/ark/"
    echo ""
    echo "  TO UPDATE SECRETS:"
    echo "  1. Stop server"
    echo "  2. Edit GameUserSettings.ini"
    echo "  3. Restart server"
    echo "╚════════════════════════════════════════════════════════════╝"
}

install_ark() {
    log "Installing ARK server..."
    mkdir -p "$INSTALL_DIR"/{server,backups,logs}

    cd "$STEAMCMD_DIR"
    ./steamcmd.sh +login anonymous +force_install_dir "$INSTALL_DIR/server" +app_update 376030 validate +quit

    cat > "$INSTALL_DIR/start-server.sh" << 'EOF'
#!/data/data/com.termux/files/usr/bin/bash
export SERVER_PASSWORD="${SERVER_PASSWORD:-changeme}"
export ADMIN_PASSWORD="${ADMIN_PASSWORD:-admin123}"
export RCON_PASSWORD="${RCON_PASSWORD:-changeme}"

cd ~/TermuxServerX/data/ark/server/ShooterGame/Binaries/Linux

./ShooterGameServer "TheIsland?Listen?SessionName=TermuxARK?ServerPassword=$SERVER_PASSWORD?ServerAdminPassword=$ADMIN_PASSWORD?MaxPlayers=10" -server -log
EOF
    chmod +x "$INSTALL_DIR/start-server.sh"
    success "ARK installed!"
}

start_ark() {
    if screen -list | grep -q "$SERVICE_NAME"; then
        echo "ARK already running"
        return 0
    fi
    cd "$INSTALL_DIR"
    screen -dmS ark ./start-server.sh
    success "ARK started"
}

stop_ark() {
    screen -S ark -X quit 2>/dev/null || true
    success "ARK stopped"
}

status_ark() {
    screen -list | grep -q "$SERVICE_NAME" && echo "ARK: RUNNING" || echo "ARK: STOPPED"
}

backup_ark() {
    mkdir -p "$BACKUP_DIR"
    tar -czf "$BACKUP_DIR/ark_$(date +%Y%m%d_%H%M%S).tar.gz" \
        -C "$INSTALL_DIR/server/ShooterGame/Saved" . 2>/dev/null || true
    success "Backup created"
}

case "$1" in
    install) install_ark ;;
    start) start_ark ;;
    stop) stop_ark ;;
    restart) stop_ark; sleep 2; start_ark ;;
    status) status_ark ;;
    backup) backup_ark ;;
    info) show_connection_info ;;
    config) show_config_info ;;
    secrets) show_secrets_info ;;
    *) cat << HELP
ARK Server Manager

Usage: ark-server.sh {command}

Commands:
  install   - Install ARK server
  start     - Start server
  stop      - Stop server
  restart   - Restart server
  status    - Check status
  backup    - Backup save data
  info      - Show connection info
  config    - Show configuration guide
  secrets   - Show credentials guide
HELP
    ;;
esac
