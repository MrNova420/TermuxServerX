#!/data/data/com.termux/files/usr/bin/bash
# 7 Days to Die Server Manager
# Full connection info, configs, credentials

SERVICE_NAME="sevendays"
INSTALL_DIR="$HOME/TermuxServerX/data/7days"
STEAMCMD_DIR="$HOME/steamcmd"
BACKUP_DIR="$HOME/TermuxServerX/backups/7days"

show_connection_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        7 Days to Die Server Connection Info               ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "  Game: 7 Days to Die"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CONNECTION DETAILS                                      │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ IP Address:    $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_PUBLIC_IP')         │"
    echo "  │ Game Port:     26900                                   │"
    echo "  │ Steam Port:    26901                                   │"
    echo "  │ Query Port:    27015                                   │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ HOW TO CONNECT                                          │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ 1. Open 7 Days to Die                                   │"
    echo "  │ 2. Press F1 for console                                 │"
    echo "  │ 3. Type: connect $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_IP'):26900        │"
    echo "  │ 4. Server Password: $SERVER_PASSWORD                     │"
    echo "  │                                                        │"
    echo "  │ Or via Steam:                                          │"
    echo "  │ 1. Open Steam > View > Servers                          │"
    echo "  │ 2. Click 'Add Server'                                   │"
    echo "  │ 3. Enter IP and connect                                 │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CREDENTIALS                                             │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ Admin Password: $ADMIN_PASSWORD                          │"
    echo "  │ Server Password: $SERVER_PASSWORD                        │"
    echo "  │                                                        │"
    echo "  │ TO BECOME ADMIN:                                       │"
    echo "  │ 1. Connect to server                                   │"
    echo "  │ 2. Press F1 and type: admin [yourpassword]             │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo "╚════════════════════════════════════════════════════════════╝"
}

show_config_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          7 Days to Die Configuration Guide                 ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    cat << 'CONFIGEOF'
  CONFIG FILES:
  ~/TermuxServerX/data/7days/serverdata/serveradmin.xml (admins)
  ~/TermuxServerX/data/7days/serverdata/servercore.xml (settings)
  ~/TermuxServerX/data/7days/serverdata/startservergame.bat (launch)

  KEY SETTINGS IN servercore.xml:
  <property name="ServerPort" value="26900"/>
  <property name="ServerIsPublic" value="true"/>
  <property name="ServerPassword" value=""/>
  <property name="ServerAdminPassword" value="YOUR_ADMIN_PASSWORD"/>
  <property name="MaxPlayers" value="8"/>
  <property name="GameMode" value="GameModeSurvival"/>
  <property name="WorldGenSeed" value="yourseed"/>
  <property name="WorldGenSize" value="8"/>
  <property name="GameName" value="MyServer"/>

  DIFFICULTY SETTINGS:
  <property name="Difficulty" value="2"/> (0-5)
  <property name="ZombieDifficulty" value="3"/> (0-4)

  MOD SUPPORT:
  Mods folder: ~/TermuxServerX/data/7days/Mods/
  Workshop mods configured in servercore.xml:
  <property name="Mods" value="modid1,modid2"/>

  IMPORTANT CONSOLE COMMANDS:
  • help - Show all commands
  • admin [password] - Become admin
  • saveworld - Manual save
  • kick [player] - Kick player
  • ban [player] - Ban player
  • shutdown - Stop server
CONFIGEOF
    echo "╚════════════════════════════════════════════════════════════╝"
}

show_secrets_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║          7 Days to Die Secrets & Security               ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo ""
    echo "  CREDENTIALS LOCATION:"
    echo "  ~/TermuxServerX/data/7days/serverdata/serveradmin.xml"
    echo "  ~/TermuxServerX/data/7days/serverdata/servercore.xml"
    echo ""
    echo "  BACKUP LOCATION:"
    echo "  ~/TermuxServerX/backups/7days/"
    echo ""
    echo "  WORLD SAVE LOCATION:"
    echo "  ~/TermuxServerX/data/7days/savegame/"
    echo ""
    echo "  ⚠️  SECURITY:"
    echo "  • Change admin password BEFORE starting server"
    echo "  • Use unique server password"
    echo "  • Regular backups essential (7-day horde!)"
    echo "  • Logs: ~/TermuxServerX/data/7days/logs/"
    echo ""
    echo "  TO RESET ADMIN PASSWORD:"
    echo "  1. Stop server"
    echo "  2. Edit serveradmin.xml"
    echo "  3. Remove entry for your player"
    echo "  4. Restart and use new password"
    echo "╚════════════════════════════════════════════════════════════╝"
}

install_7days() {
    mkdir -p "$INSTALL_DIR"/{server,backups,serverdata}
    cd "$STEAMCMD_DIR"
    ./steamcmd.sh +login anonymous +force_install_dir "$INSTALL_DIR/server" +app_update 294420 validate +quit
    echo "[+] 7 Days to Die installed"
}

start_7days() {
    screen -dmS sevendays "$INSTALL_DIR/server/7DaysToDieServer.sh -configfile=servercore.xml"
    echo "[+] Server started"
}

stop_7days() {
    screen -S sevendays -X quit 2>/dev/null
    echo "[+] Server stopped"
}

backup_7days() {
    mkdir -p "$BACKUP_DIR"
    tar -czf "$BACKUP_DIR/7days_$(date +%Y%m%d_%H%M%S).tar.gz" \
        -C "$INSTALL_DIR" savegame serverdata 2>/dev/null || true
    echo "[+] Backup created"
}

case "$1" in
    install) install_7days ;;
    start) start_7days ;;
    stop) stop_7days ;;
    restart) stop_7days; sleep 2; start_7days ;;
    backup) backup_7days ;;
    info) show_connection_info ;;
    config) show_config_info ;;
    secrets) show_secrets_info ;;
    *) echo "Usage: $0 {install|start|stop|restart|backup|info|config|secrets}" ;;
esac
