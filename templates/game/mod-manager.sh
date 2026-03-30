#!/data/data/com.termux/files/usr/bin/bash
# Universal Game Server Mod Manager
# Supports: Minecraft (Spigot/Paper/Fabric), Valheim, Palworld, CS:GO, Rust

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
CONFIG_DIR="$HOME/TermuxServerX/config"
GAME_DIR="$HOME/TermuxServerX/data"

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

log_info() { echo -e "${BLUE}[INFO]${NC} $1"; }
log_success() { echo -e "${GREEN}[OK]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

show_menu() {
    clear
    echo "╔════════════════════════════════════════════════╗"
    echo "║       Game Server Mod Manager                  ║"
    echo "╠════════════════════════════════════════════════╣"
    echo "║  1) Minecraft - Install Mods                   ║"
    echo "║  2) Minecraft - Install Plugins                ║"
    echo "║  3) Minecraft - Modpack Manager                ║"
    echo "║  4) Valheim - Install Mods                     ║"
    echo "║  5) Palworld - Install Mods                    ║"
    echo "║  6) CS:GO - Install Plugins                   ║"
    echo "║  7) Rust - Install Plugins                     ║"
    echo "║  8) Download Mod by URL                        ║"
    echo "║  9) List Installed Mods                        ║"
    echo "║  10) Update All Mods                          ║"
    echo "║  11) Backup Mods                              ║"
    echo "║  0) Exit                                      ║"
    echo "╚════════════════════════════════════════════════╝"
    read -p "Select option: " choice
}

install_minecraft_mods() {
    clear
    echo "=== Minecraft Mod Manager ==="
    echo "1) Fabric Mods"
    echo "2) Forge Mods"
    echo "3) Paper/Spigot Plugins"
    read -p "Select modloader: " loader

    case $loader in
        1) install_fabric_mods ;;
        2) install_forge_mods ;;
        3) install_spigot_plugins ;;
    esac
}

install_fabric_mods() {
    MOD_DIR="$GAME_DIR/minecraft/mods"
    mkdir -p "$MOD_DIR"

    echo "Enter Fabric mod URLs (one per line, empty to finish):"
    while read -p "URL: " url && [ -n "$url" ]; do
        filename=$(basename "$url")
        log_info "Downloading $filename..."
        curl -L -o "$MOD_DIR/$filename" "$url" 2>/dev/null && \
            log_success "Downloaded $filename" || \
            log_error "Failed to download $filename"
    done

    log_success "Fabric mods installed to $MOD_DIR"
}

install_forge_mods() {
    MOD_DIR="$GAME_DIR/minecraft/mods"
    mkdir -p "$MOD_DIR"

    echo "Enter Forge mod URLs (one per line, empty to finish):"
    while read -p "URL: " url && [ -n "$url" ]; do
        filename=$(basename "$url")
        log_info "Downloading $filename..."
        curl -L -o "$MOD_DIR/$filename" "$url" 2>/dev/null && \
            log_success "Downloaded $filename" || \
            log_error "Failed to download $filename"
    done

    log_success "Forge mods installed to $MOD_DIR"
}

install_spigot_plugins() {
    PLUGIN_DIR="$GAME_DIR/minecraft/plugins"
    mkdir -p "$PLUGIN_DIR"

    echo "Enter plugin URLs (one per line, empty to finish):"
    while read -p "URL: " url && [ -n "$url" ]; do
        filename=$(basename "$url")
        log_info "Downloading $filename..."
        curl -L -o "$PLUGIN_DIR/$filename" "$url" 2>/dev/null && \
            log_success "Downloaded $filename" || \
            log_error "Failed to download $filename"
    done

    log_success "Plugins installed to $PLUGIN_DIR"
}

install_valheim_mods() {
    MOD_DIR="$GAME_DIR/valheim/BepInEx/plugins"
    mkdir -p "$MOD_DIR"

    echo "=== Valheim Mod Manager ==="
    echo "Popular mods: Jötunn, Equipment and Quick Slots, Better-archaeology"
    echo "Enter mod URLs (one per line, empty to finish):"

    while read -p "URL: " url && [ -n "$url" ]; do
        filename=$(basename "$url")
        log_info "Downloading $filename..."
        curl -L -o "$MOD_DIR/$filename" "$url" 2>/dev/null && \
            log_success "Downloaded $filename" || \
            log_error "Failed to download $filename"
    done

    log_success "Valheim mods installed to $MOD_DIR"
}

install_palworld_mods() {
    MOD_DIR="$GAME_DIR/palworld/mods"
    mkdir -p "$MOD_DIR"

    echo "=== Palworld Mod Manager ==="
    echo "Enter mod URLs (one per line, empty to finish):"

    while read -p "URL: " url && [ -n "$url" ]; do
        filename=$(basename "$url")
        log_info "Downloading $filename..."
        curl -L -o "$MOD_DIR/$filename" "$url" 2>/dev/null && \
            log_success "Downloaded $filename" || \
            log_error "Failed to download $filename"
    done

    log_success "Palworld mods installed to $MOD_DIR"
}

install_csgo_plugins() {
    PLUGIN_DIR="$GAME_DIR/csgo/server/csgo/addons"
    mkdir -p "$PLUGIN_DIR"

    echo "=== CS:GO/CS2 Plugin Manager ==="
    echo "For SourceMod and Metamod plugins"
    echo "Enter plugin URLs (.sp or .smx files):"

    while read -p "URL: " url && [ -n "$url" ]; do
        filename=$(basename "$url")
        log_info "Downloading $filename..."
        curl -L -o "$MOD_DIR/$filename" "$url" 2>/dev/null && \
            log_success "Downloaded $filename" || \
            log_error "Failed to download $filename"
    done

    log_success "CS:GO plugins installed"
}

install_rust_plugins() {
    PLUGIN_DIR="$GAME_DIR/rust/server/Oxide/plugins"
    mkdir -p "$PLUGIN_DIR"

    echo "=== Rust Plugin Manager (Oxide) ==="
    echo "Enter plugin URLs:"
    while read -p "URL: " url && [ -n "$url" ]; do
        filename=$(basename "$url")
        log_info "Downloading $filename..."
        curl -L -o "$PLUGIN_DIR/$filename" "$url" 2>/dev/null && \
            log_success "Downloaded $filename" || \
            log_error "Failed to download $filename"
    done

    log_success "Rust plugins installed"
}

download_mod_url() {
    clear
    echo "=== Download Mod by URL ==="
    read -p "Enter game type (minecraft/valheim/palworld/csgo/rust): " game
    read -p "Enter mod URL: " url

    case $game in
        minecraft) DIR="$GAME_DIR/minecraft/mods" ;;
        valheim) DIR="$GAME_DIR/valheim/BepInEx/plugins" ;;
        palworld) DIR="$GAME_DIR/palworld/mods" ;;
        csgo) DIR="$GAME_DIR/csgo/server/csgo/addons" ;;
        rust) DIR="$GAME_DIR/rust/server/Oxide/plugins" ;;
        *) log_error "Unknown game: $game"; return ;;
    esac

    mkdir -p "$DIR"
    filename=$(basename "$url")
    log_info "Downloading $filename..."
    curl -L -o "$DIR/$filename" "$url" && log_success "Downloaded!" || log_error "Failed!"
}

list_installed_mods() {
    clear
    echo "=== Installed Mods ==="

    for game in minecraft valheim palworld csgo rust; do
        case $game in
            minecraft) DIR="$GAME_DIR/minecraft/mods"; DIR2="$GAME_DIR/minecraft/plugins" ;;
            valheim) DIR="$GAME_DIR/valheim/BepInEx/plugins" ;;
            palworld) DIR="$GAME_DIR/palworld/mods" ;;
            csgo) DIR="$GAME_DIR/csgo/server/csgo/addons" ;;
            rust) DIR="$GAME_DIR/rust/server/Oxide/plugins" ;;
        esac

        echo -e "\n${GREEN}=== $game ===${NC}"
        if [ -d "$DIR" ] && [ "$(ls -A $DIR 2>/dev/null)" ]; then
            ls -lh "$DIR" | tail -n +2
        else
            echo "  No mods installed"
        fi
        if [ -d "$DIR2" ] && [ "$(ls -A $DIR2 2>/dev/null)" ]; then
            ls -lh "$DIR2" | tail -n +2
        fi
    done
}

update_all_mods() {
    log_warn "Update functionality requires re-downloading mods from original sources"
    echo "Consider using mod manager platforms for easier updates."
    read -p "Press Enter to continue..."
}

backup_mods() {
    BACKUP_DIR="$HOME/TermuxServerX/backups/mods"
    mkdir -p "$BACKUP_DIR"

    timestamp=$(date +%Y%m%d_%H%M%S)
    backup_file="$BACKUP_DIR/mods_backup_$timestamp.tar.gz"

    log_info "Creating mods backup..."
    tar -czf "$backup_file" -C "$HOME/TermuxServerX/data" \
        minecraft/mods minecraft/plugins \
        valheim/BepInEx palworld/mods \
        csgo/server/csgo/addons \
        rust/server/Oxide 2>/dev/null || true

    if [ -f "$backup_file" ]; then
        log_success "Backup created: $backup_file"
        echo "Backup size: $(du -h $backup_file | cut -f1)"
    else
        log_error "Backup failed"
    fi
}

case "$1" in
    menu) show_menu ;;
    mc-mods) install_minecraft_mods ;;
    mc-plugins) install_spigot_plugins ;;
    valheim-mods) install_valheim_mods ;;
    palworld-mods) install_palworld_mods ;;
    csgo-plugins) install_csgo_plugins ;;
    rust-plugins) install_rust_plugins ;;
    download) download_mod_url ;;
    list) list_installed_mods ;;
    backup) backup_mods ;;
    *)
        while true; do
            show_menu
            case $choice in
                1) install_minecraft_mods ;;
                2) install_spigot_plugins ;;
                3) log_info "Use modpack manager option" ;;
                4) install_valheim_mods ;;
                5) install_palworld_mods ;;
                6) install_csgo_plugins ;;
                7) install_rust_plugins ;;
                8) download_mod_url ;;
                9) list_installed_mods ;;
                10) update_all_mods ;;
                11) backup_mods ;;
                0) exit 0 ;;
            esac
            read -p "Press Enter to continue..."
        done
        ;;
esac
