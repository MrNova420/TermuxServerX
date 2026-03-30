#!/data/data/com.termux/files/usr/bin/bash
# Source Engine Game Servers Manager
# Supports: CS:GO, CS2, TF2, L4D2, DOD:S, GMOD

SERVICE_NAME="source"
INSTALL_DIR="$HOME/TermuxServerX/data/source"
STEAMCMD_DIR="$HOME/steamcmd"
BACKUP_DIR="$HOME/TermuxServerX/backups/source"

GAME_IDS=(
    "csgo:740"
    "cs2:730"
    "tf2:232250"
    "l4d2:222860"
    "dods:232290"
    "gmod:4000"
)

show_connection_info() {
    local game=$1
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        Source Engine Server - Connection Info             ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "  Game: $(echo $game | tr '[:lower:]' '[:upper:]')"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ CONNECTION DETAILS                                      │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ IP Address:    $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_PUBLIC_IP')         │"
    echo "  │ Game Port:     27015                                   │"
    echo "  │ Source TV:     27020                                   │"
    echo "  │ RCON Password: $RCON_PASSWORD                           │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ HOW TO CONNECT                                          │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ 1. Open game                                            │"
    echo "  │ 2. Open console (~)                                     │"
    echo "  │ 3. Type: connect $(curl -s ifconfig.me 2>/dev/null || echo 'YOUR_IP'):27015              │"
    echo "  │                                                        │"
    echo "  │ Via Steam:                                             │"
    echo "  │ View > Servers > Favorites > Add Server                │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo ""
    echo "  ┌─────────────────────────────────────────────────────────┐"
    echo "  │ RCON COMMANDS                                          │"
    echo "  ├─────────────────────────────────────────────────────────┤"
    echo "  │ rcon_password <password>  - Authenticate               │"
    echo "  │ rcon status               - Server info               │"
    echo "  │ rcon changelevel <map>     - Change map                │"
    echo "  │ rcon kick <player>         - Kick player               │"
    echo "  │ rcon ban <player>          - Ban player                │"
    echo "  │ rcon sv_restart            - Restart round            │"
    echo "  └─────────────────────────────────────────────────────────┘"
    echo "╚════════════════════════════════════════════════════════════╝"
}

show_secrets_info() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        Source Engine Server - Credentials & Security      ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo ""
    echo "  CONFIG FILES:"
    echo "  ~/TermuxServerX/data/source/<game>/csgo/cfg/server.cfg"
    echo "  ~/TermuxServerX/data/source/<game>/csgo/cfg/rcon.cfg"
    echo ""
    echo "  KEY CREDENTIALS IN server.cfg:"
    echo "  • rcon_password - Remote console access"
    echo "  • sv_password - Server join password"
    echo "  • sv_tags - Server tags for matchmaking"
    echo ""
    echo "  STEAM GAME IDS:"
    echo "  • CS:GO - 740"
    echo "  • CS2 - 730"
    echo "  • TF2 - 232250"
    echo "  • L4D2 - 222860"
    echo "  • Garry's Mod - 4000"
    echo ""
    echo "  BACKUP FILES:"
    echo "  ~/TermuxServerX/backups/source/"
    echo ""
    echo "  ⚠️  SECURITY:"
    echo "  • Change rcon_password immediately"
    echo "  • Use sv_password for private servers"
    echo "  • Regular backups recommended"
    echo "╚════════════════════════════════════════════════════════════╝"
}

install_game() {
    local game=$1
    local app_id=$(echo $GAME_IDS | grep $game | cut -d: -f2)

    mkdir -p "$INSTALL_DIR/$game"
    cd "$STEAMCMD_DIR"
    ./steamcmd.sh +login anonymous +force_install_dir "$INSTALL_DIR/$game/server" +app_update "$app_id" validate +quit

    cat > "$INSTALL_DIR/$game/start.sh" << EOF
#!/bin/bash
cd ~/TermuxServerX/data/source/$game/server/csgo
./srcds_run -game csgo -console -port 27015 +map de_dust2 +maxplayers 10 +sv_setsteamaccount ""
EOF
    chmod +x "$INSTALL_DIR/$game/start.sh"
    echo "[+] $game installed"
}

start_game() {
    local game=$1
    screen -dmS "source-$game" "$INSTALL_DIR/$game/start.sh"
    echo "[+] $game started"
}

stop_game() {
    local game=$1
    screen -S "source-$game" -X quit 2>/dev/null
    echo "[+] $game stopped"
}

show_menu() {
    clear
    echo "╔════════════════════════════════════════════════════════════╗"
    echo "║        Source Engine Server Manager                       ║"
    echo "╠════════════════════════════════════════════════════════════╣"
    echo "║  1) CS:GO (740)                                          ║"
    echo "║  2) CS2 (730)                                            ║"
    echo "║  3) TF2 (232250)                                         ║"
    echo "║  4) L4D2 (222860)                                        ║"
    echo "║  5) Garry's Mod (4000)                                    ║"
    echo "║  6) Info - Connection Guide                             ║"
    echo "║  7) Secrets - Credentials Guide                         ║"
    echo "║  0) Exit                                                 ║"
    echo "╚════════════════════════════════════════════════════════════╝"
}

case "$1" in
    csgo) install_game csgo; start_game csgo; show_connection_info csgo ;;
    cs2) install_game cs2; start_game cs2; show_connection_info cs2 ;;
    tf2) install_game tf2; start_game tf2; show_connection_info tf2 ;;
    l4d2) install_game l4d2; start_game l4d2; show_connection_info l4d2 ;;
    gmod) install_game gmod; start_game gmod; show_connection_info gmod ;;
    info) show_connection_info csgo ;;
    secrets) show_secrets_info ;;
    *)
        show_menu
        read -p "Select: " sel
        case $sel in
            1) install_game csgo; start_game csgo; show_connection_info csgo ;;
            2) install_game cs2; start_game cs2; show_connection_info cs2 ;;
            3) install_game tf2; start_game tf2; show_connection_info tf2 ;;
            4) install_game l4d2; start_game l4d2; show_connection_info l4d2 ;;
            5) install_game gmod; start_game gmod; show_connection_info gmod ;;
            6) show_connection_info csgo ;;
            7) show_secrets_info ;;
        esac
        ;;
esac
