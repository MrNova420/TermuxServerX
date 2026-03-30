#!/bin/bash
# TermuxServerX - Elite Game Server Manager
# One-click game server control panel

TSX_DIR="$HOME/TermuxServerX"
source "$TSX_DIR/config.env" 2>/dev/null || true

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }

is_running() { screen -list | grep -q "$1"; }

show_menu() {
    clear
    echo -e "${CYAN}"
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║           Game Server Control Panel v2.0                 ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo -e "${NC}"
    
    echo -e "${BLUE}[ GAME SERVERS ]${NC}"
    echo "  [1] Minecraft Java    - Port: 25565"
    echo "  [2] PocketMine (PE)    - Port: 19135"
    echo "  [3] Terraria         - Port: 7777"
    echo ""
    echo -e "${BLUE}[ ACTIONS ]${NC}"
    echo "  [s] Start Selected Server"
    echo "  [x] Stop Selected Server"
    echo "  [r] Restart Selected Server"
    echo "  [l] View Logs"
    echo "  [b] Backup Server"
    echo "  [c] Console Access"
    echo "  [a] Start ALL Servers"
    echo "  [z] Stop ALL Servers"
    echo ""
    echo -e "${BLUE}[ INFO ]${NC}"
    echo "  [i] Server Info"
    echo "  [p] Player List"
    echo "  [w] Server Resources"
    echo ""
    echo "  [0] Back to Main Menu"
    echo ""
}

show_status() {
    echo -e "\n${BLUE}[ Server Status ]${NC}\n"
    
    for server in "minecraft" "pocketmine" "terraria"; do
        if is_running "$server"; then
            echo -e "  $server: ${GREEN}● RUNNING${NC}"
        else
            echo -e "  $server: ${RED}○ STOPPED${NC}"
        fi
    done
}

start_server() {
    local server=$1
    log "Starting $server..."
    
    case $server in
        minecraft)
            cd "$TSX_DIR/data/minecraft" && screen -dmS minecraft ./start.sh
            ;;
        pocketmine)
            cd "$TSX_DIR/data/pocketmine" && screen -dmS pocketmine ./start.sh
            ;;
        terraria)
            cd "$TSX_DIR/data/terraria" && screen -dmS terraria ./start.sh
            ;;
    esac
    
    sleep 2
    is_running "$server" && log "$server started!" || warn "Failed to start $server"
}

stop_server() {
    local server=$1
    log "Stopping $server..."
    
    case $server in
        minecraft) screen -S minecraft -X stuff 'stop\n' ;;
        pocketmine) screen -S pocketmine -X stuff 'stop\n' ;;
        terraria) screen -S terraria -X stuff 'exit\n' ;;
    esac
    
    sleep 3
    ! is_running "$server" && log "$server stopped!" || warn "Failed to stop $server"
}

view_logs() {
    local server=$1
    case $server in
        minecraft) tail -50 "$TSX_DIR/logs/minecraft/latest.log" ;;
        pocketmine) tail -50 "$TSX_DIR/data/pocketmine/server.log" ;;
        terraria) tail -50 "$TSX_DIR/logs/terraria/server.log" ;;
    esac
}

backup_server() {
    local server=$1
    local backup_dir="$TSX_DIR/backups/games"
    mkdir -p "$backup_dir"
    
    log "Backing up $server..."
    
    case $server in
        minecraft)
            tar -czf "$backup_dir/minecraft_$(date +%Y%m%d_%H%M%S).tar.gz" \
                -C "$TSX_DIR/data/minecraft" world/ world_nether/ world_the_end/ 2>/dev/null
            ;;
        pocketmine)
            tar -czf "$backup_dir/pocketmine_$(date +%Y%m%d_%H%M%S).tar.gz" \
                -C "$TSX_DIR/data/pocketmine" worlds/ plugins/ 2>/dev/null
            ;;
        terraria)
            tar -czf "$backup_dir/terraria_$(date +%Y%m%d_%H%M%S).tar.gz" \
                -C "$TSX_DIR/data/terraria" world.wld 2>/dev/null
            ;;
    esac
    
    log "Backup complete!"
}

console_access() {
    local server=$1
    log "Opening console (Ctrl+A, D to detach)..."
    screen -r "$server"
}

server_info() {
    local server=$1
    
    echo -e "\n${BLUE}[ $server Info ]${NC}\n"
    
    case $server in
        minecraft)
            echo "  Type: Minecraft Java Edition"
            echo "  JAR: PaperMC latest"
            echo "  RAM: ${TSX_JAVA_RAM:-1536M}"
            echo "  World: ~/TermuxServerX/data/minecraft/world"
            ;;
        pocketmine)
            echo "  Type: PocketMine-MP (Bedrock/PE)"
            echo "  PHP Version: Latest"
            echo "  World: ~/TermuxServerX/data/pocketmine/worlds"
            ;;
        terraria)
            echo "  Type: Terraria Server"
            echo "  Port: 7777"
            echo "  World: ~/TermuxServerX/data/terraria"
            ;;
    esac
}

main() {
    while true; do
        show_status
        show_menu
        
        echo -n "Select option: "
        read choice
        
        case $choice in
            1) start_server minecraft ;;
            2) start_server pocketmine ;;
            3) start_server terraria ;;
            s) 
                echo -n "Which server (minecraft/pocketmine/terraria)? "
                read srv; start_server "$srv" ;;
            x) 
                echo -n "Which server (minecraft/pocketmine/terraria)? "
                read srv; stop_server "$srv" ;;
            r) 
                echo -n "Which server (minecraft/pocketmine/terraria)? "
                read srv; stop_server "$srv"; sleep 2; start_server "$srv" ;;
            l) 
                echo -n "Which server (minecraft/pocketmine/terraria)? "
                read srv; view_logs "$srv" ;;
            b) 
                echo -n "Which server (minecraft/pocketmine/terraria)? "
                read srv; backup_server "$srv" ;;
            c) 
                echo -n "Which server (minecraft/pocketmine/terraria)? "
                read srv; console_access "$srv" ;;
            a) 
                start_server minecraft
                start_server pocketmine
                start_server terraria
                ;;
            z)
                stop_server minecraft
                stop_server pocketmine
                stop_server terraria
                ;;
            i)
                echo -n "Which server (minecraft/pocketmine/terraria)? "
                read srv; server_info "$srv" ;;
            0) exit 0 ;;
        esac
        
        [ "$choice" != "c" ] && echo -n "Press Enter..." && read
    done
}

main "$@"
