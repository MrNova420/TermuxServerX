#!/bin/bash
# Master Game Server Manager
# Lists all games, shows connection info, manages all

INSTALL_DIR="$HOME/TermuxServerX"
GAMES_DIR="$INSTALL_DIR/templates"

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m'

show_all_games() {
    clear
    MY_IP=$(curl -s ifconfig.me 2>/dev/null || echo "YOUR_IP")
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║           ALL GAME SERVERS - CONNECTION INFO                    ║"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    echo "║                                                                  ║"
    echo "║  Your Public IP: ${GREEN}$MY_IP${NC}                                      ║"
    echo "║                                                                  ║"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    echo "║  ${GREEN}JAVA EDITION SERVERS${NC}                                           ║"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    printf "║  %-15s │ %-15s │ %-25s ║\n" "Game" "Port" "How to Connect"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    printf "║  %-15s │ %-15s │ %s ║\n" "Minecraft (Java)" "25565" "Java > Multiplayer > Direct > $MY_IP:25565"
    printf "║  %-15s │ %-15s │ %s ║\n" "Minecraft (Bedrock)" "19132" "Bedrock > Servers > $MY_IP:19132"
    printf "║  %-15s │ %-15s │ %s ║\n" "Valheim" "2456" "Steam > Valheim > Join > $MY_IP:2456"
    printf "║  %-15s │ %-15s │ %s ║\n" "Terraria" "7777" "Terraria > Multiplayer > $MY_IP:7777"
    printf "║  %-15s │ %-15s │ %s ║\n" "Ark Survival" "7778" "Steam > Ark > Join > $MY_IP:7778"
    printf "║  %-15s │ %-15s │ %s ║\n" "7 Days to Die" "26900" "Steam > Join IP > $MY_IP:26900"
    printf "║  %-15s │ %-15s │ %s ║\n" "Rust" "28015" "Rust > Connect > $MY_IP:28015"
    printf "║  %-15s │ %-15s │ %s ║\n" "DayZ" "2302" "Steam > DayZ > Browse > $MY_IP:2302"
    printf "║  %-15s │ %-15s │ %s ║\n" "Palworld" "8211" "Steam > Palworld > Join > $MY_IP:8211"
    printf "║  %-15s │ %-15s │ %s ║\n" "Conan Exiles" "7777" "Steam > Join > $MY_IP:7777"
    printf "║  %-15s │ %-15s │ %s ║\n" "Satisfactory" "7777" "Steam > Satisfactory > Host > $MY_IP:7777"
    printf "║  %-15s │ %-15s │ %s ║\n" "StarMade" "4242" "StarMade > Connect > $MY_IP:4242"
    printf "║  %-15s │ %-15s │ %s ║\n" "Eco" "3000" "Eco > Join Game > $MY_IP:3000"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    echo "║  ${BLUE}SOURCE ENGINE SERVERS${NC}                                        ║"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    printf "║  %-15s │ %-15s │ %s ║\n" "CS:GO" "27015" "CS:GO > Console > connect $MY_IP"
    printf "║  %-15s │ %-15s │ %s ║\n" "CS2" "27015" "CS2 > Console > connect $MY_IP"
    printf "║  %-15s │ %-15s │ %s ║\n" "TF2" "27015" "TF2 > Console > connect $MY_IP"
    printf "║  %-15s │ %-15s │ %s ║\n" "L4D2" "27015" "L4D2 > Play > Join > $MY_IP"
    printf "║  %-15s │ %-15s │ %s ║\n" "Garry's Mod" "27015" "GMOD > Join > $MY_IP"
    echo "╚══════════════════════════════════════════════════════════════════╝"
}

show_detailed_info() {
    clear
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║           DETAILED GAME SERVER INFO                            ║"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    echo "║                                                                  ║"
    echo "║  Select a game for detailed connection info & credentials:     ║"
    echo "║                                                                  ║"
    echo "║  ${GREEN}JAVA GAMES${NC}                                                     ║"
    echo "║    1) Minecraft Java    2) Valheim    3) Terraria              ║"
    echo "║    4) 7 Days to Die     5) Rust       6) ARK                   ║"
    echo "║    7) DayZ              8) Palworld   9) Conan Exiles           ║"
    echo "║   10) Satisfactory     11) StarMade  12) Eco                   ║"
    echo "║                                                                  ║"
    echo "║  ${BLUE}SOURCE ENGINE${NC}                                                   ║"
    echo "║   13) CS:GO             14) CS2       15) TF2                   ║"
    echo "║   16) L4D2             17) Garry's Mod                          ║"
    echo "║                                                                  ║"
    echo "║  ${YELLOW}BEDROCK/OTHER${NC}                                                   ║"
    echo "║   18) Minecraft Bedrock 19) PocketMine                          ║"
    echo "║                                                                  ║"
    echo "║    0) Back to main menu                                         ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
    read -p "Select game: " choice

    case $choice in
        1) bash "$GAMES_DIR/minecraft/minecraft-manager.sh" info 2>/dev/null || echo "Run 'minecraft-server.sh info' for details" ;;
        2) bash "$GAMES_DIR/valheim/valheim-manager.sh" info 2>/dev/null || echo "Run 'valheim-manager.sh info'" ;;
        3) bash "$GAMES_DIR/game/terraria-manager.sh" info 2>/dev/null || echo "Run 'terraria-manager.sh info'" ;;
        4) bash "$GAMES_DIR/seven_days/7days-manager.sh" info 2>/dev/null || echo "Run '7days-manager.sh info'" ;;
        5) bash "$GAMES_DIR/rust/rust-manager.sh" info 2>/dev/null || echo "Run 'rust-manager.sh info'" ;;
        6) bash "$GAMES_DIR/ark/ark-manager.sh" info 2>/dev/null || echo "Run 'ark-manager.sh info'" ;;
        7) bash "$GAMES_DIR/dayz/dayz-manager.sh" info 2>/dev/null || echo "Run 'dayz-manager.sh info'" ;;
        8) bash "$GAMES_DIR/palworld/palworld-manager.sh" info 2>/dev/null || echo "Run 'palworld-manager.sh info'" ;;
        9) bash "$GAMES_DIR/ConanExiles/conan-manager.sh" info 2>/dev/null || echo "Run 'conan-manager.sh info'" ;;
        10) bash "$GAMES_DIR/satisfactory/satisfactory-manager.sh" info 2>/dev/null || echo "Run 'satisfactory-manager.sh info'" ;;
        11) bash "$GAMES_DIR/starmade/starmade-manager.sh" info 2>/dev/null || echo "Run 'starmade-manager.sh info'" ;;
        12) bash "$GAMES_DIR/eco/eco-manager.sh" info 2>/dev/null || echo "Run 'eco-manager.sh info'" ;;
        13|14|15|16|17) bash "$GAMES_DIR/SOURCE_ENGINE/source-manager.sh" info 2>/dev/null || echo "Run 'source-manager.sh info'" ;;
        18) bash "$GAMES_DIR/game/pocketmine-manager.sh" info 2>/dev/null || echo "Run 'pocketmine-manager.sh info'" ;;
        0) return ;;
    esac
}

show_public_private_info() {
    clear
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║           PUBLIC vs PRIVATE SERVER OPTIONS                     ║"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    cat << 'EOF'

  ┌─────────────────────────────────────────────────────────────────────┐
  │                         PUBLIC SERVER                              │
  ├─────────────────────────────────────────────────────────────────────┤
  │                                                                     │
  │  WHAT IT MEANS:                                                    │
  │  • Anyone with your IP can try to connect                          │
  │  • Server appears in public server lists (if configured)           │
  │  • No authentication required to join                              │
  │                                                                     │
  │  USE WHEN:                                                         │
  │  ✓ Public game servers (Minecraft, Valheim, etc.)                 │
  │  ✓ You want random players to join                                │
  │  ✓ Testing/development purposes                                   │
  │                                                                     │
  │  HOW TO:                                                           │
  │  1. Set no password or simple password                            │
  │  2. Enable server visibility in game                              │
  │  3. Share IP with players                                        │
  │                                                                     │
  └─────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────┐
  │                        PRIVATE SERVER                               │
  ├─────────────────────────────────────────────────────────────────────┤
  │                                                                     │
  │  WHAT IT MEANS:                                                    │
  │  • Only invited players can connect                               │
  │  • Requires password or whitelist                                  │
  │  • Server hidden from public lists                                 │
  │                                                                     │
  │  USE WHEN:                                                         │
  │  ✓ Playing with friends only                                       │
  │  ✓ Hosting personal services                                      │
  │  ✓ Security is important                                           │
  │                                                                     │
  │  HOW TO:                                                           │
  │  1. Set strong server password                                     │
  │  2. Enable whitelist if supported                                  │
  │  3. Only share password with trusted players                        │
  │  4. Use access-control.sh to manage IPs                           │
  │                                                                     │
  └─────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────┐
  │                      FRIENDS-ONLY SERVER                             │
  ├─────────────────────────────────────────────────────────────────────┤
  │                                                                     │
  │  WHAT IT MEANS:                                                    │
  │  • Only specific IPs can connect                                   │
  │  • Extra layer of security beyond password                         │
  │  • You control who can access                                      │
  │                                                                     │
  │  USE WHEN:                                                         │
  │  ✓ You know your friends' IP addresses                            │
  │  ✓ Maximum security needed                                         │
  │  ✓ Prevent unauthorized access attempts                           │
  │                                                                     │
  │  HOW TO:                                                           │
  │  1. Run: ~/TermuxServerX/scripts/access-control.sh               │
  │  2. Select "Friends" mode                                          │
  │  3. Add your friends' IP addresses to whitelist                   │
  │                                                                     │
  └─────────────────────────────────────────────────────────────────────┘

EOF
    echo "Press Enter to continue..."
    read
}

show_password_sharing() {
    clear
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║           SECURE PASSWORD SHARING GUIDE                        ║"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    cat << 'EOF'

  ┌─────────────────────────────────────────────────────────────────────┐
  │                    WAYS TO SHARE PASSWORDS                          │
  ├─────────────────────────────────────────────────────────────────────┤
  │                                                                     │
  │  1. DIRECT MESSAGE (Best for close friends)                        │
  │     • Send password via Discord DM, WhatsApp, Signal               │
  │     • Don't share in group chats                                    │
  │     • Delete messages after server join                             │
  │                                                                     │
  │  2. ENCRYPTED MESSAGE                                              │
  │     • Use encrypted messaging apps (Signal, Telegram)               │
  │     • Better for public communities                                 │
  │                                                                     │
  │  3. ONE-TIME LINKS                                                │
  │     • Use services like onetimesecret.com                          │
  │     • Auto-deletes after reading                                    │
  │                                                                     │
  │  4. SPLIT THE PASSWORD                                             │
  │     • Share half via text, half via voice call                     │
  │     • Unlikely to be intercepted                                   │
  │                                                                     │
  └─────────────────────────────────────────────────────────────────────┘

  ┌─────────────────────────────────────────────────────────────────────┐
  │                    PASSWORD SHARING DON'Ts                          │
  ├─────────────────────────────────────────────────────────────────────┤
  │                                                                     │
  │  ✗ Don't post passwords in Discord general chat                    │
  │  ✗ Don't include in screenshots (can be searched)                   │
  │  ✗ Don't use same password for everything                           │
  │  ✗ Don't share admin passwords with all players                    │
  │  ✗ Don't send via email (often unencrypted)                         │
  │                                                                     │
  └─────────────────────────────────────────────────────────────────────┘

EOF
    echo "Press Enter to continue..."
    read
}

show_menu() {
    clear
    echo "╔══════════════════════════════════════════════════════════════════╗"
    echo "║         TERMUXSERVERX GAME SERVER MANAGER                      ║"
    echo "╠══════════════════════════════════════════════════════════════════╣"
    echo "║                                                                  ║"
    echo "║  1) View All Games Connection Info                            ║"
    echo "║  2) Detailed Game Info & Credentials                          ║"
    echo "║  3) Public vs Private Server Guide                            ║"
    echo "║  4) Password Sharing Best Practices                           ║"
    echo "║  5) Access Control Manager (IP whitelist)                      ║"
    echo "║  6) Generate Shareable Connection Links                       ║"
    echo "║  7) Install All Game Servers                                  ║"
    echo "║  8) Manage Mods for All Games                                 ║"
    echo "║  0) Exit                                                      ║"
    echo "║                                                                  ║"
    echo "╚══════════════════════════════════════════════════════════════════╝"
}

main() {
    while true; do
        show_menu
        read -p "Select option: " choice

        case $choice in
            1) show_all_games; read -p "Press Enter to continue..." ;;
            2) show_detailed_info ;;
            3) show_public_private_info ;;
            4) show_password_sharing ;;
            5) bash "$INSTALL_DIR/scripts/access-control.sh" ;;
            6) bash "$INSTALL_DIR/scripts/access-control.sh" links ;;
            7) echo "Run ~/TermuxServerX/scripts/stacks/install-stack.sh games" ;;
            8) bash "$INSTALL_DIR/templates/game/mod-manager.sh" ;;
            0) exit 0 ;;
        esac
    done
}

case "$1" in
    list|all) show_all_games ;;
    info) show_detailed_info ;;
    public) show_public_private_info ;;
    passwords) show_password_sharing ;;
    access) bash "$INSTALL_DIR/scripts/access-control.sh" ;;
    *) main ;;
esac
