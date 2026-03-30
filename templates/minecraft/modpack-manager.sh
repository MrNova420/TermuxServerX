#!/data/data/com.termux/files/usr/bin/bash
# Ultimate Minecraft Modpack Manager
# Creates and manages modpacks for Fabric/Forge/Quilt

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
BLUE='\033[0;34m'
NC='\033[0m'

MINECRAFT_DIR="$HOME/TermuxServerX/data/minecraft"
MOD_DIR="$MINECRAFT_DIR/mods"
CONFIG_DIR="$MINECRAFT_DIR/config"
MODPACK_DIR="$HOME/TermuxServerX/modpacks"

log() { echo -e "${BLUE}[*]${NC} $1"; }
success() { echo -e "${GREEN}[+]${NC} $1"; }

select_loader() {
    clear
    echo "=== Select Mod Loader ==="
    echo "1) Fabric (Lightweight, fast startup)"
    echo "2) Forge (Most mods support)"
    echo "3) Quilt (Fabric fork, modern)"
    echo "4) NeoForge (Forge successor)"
    read -p "Choice: " loader

    case $loader in
        1) LOADER="fabric"; MC_VER="1.20.4" ;;
        2) LOADER="forge"; MC_VER="1.20.4" ;;
        3) LOADER="quilt"; MC_VER="1.20.4" ;;
        4) LOADER="neoforge"; MC_VER="1.20.4" ;;
    esac
    log "Selected: $LOADER for Minecraft $MC_VER"
}

select_minecraft_version() {
    echo "Select Minecraft version:"
    echo "1) 1.20.4 (Latest)"
    echo "2) 1.20.2"
    echo "3) 1.19.4"
    echo "4) 1.18.2"
    echo "5) 1.16.5"
    echo "6) Custom version"
    read -p "Choice: " ver

    case $ver in
        1) MC_VER="1.20.4" ;;
        2) MC_VER="1.20.2" ;;
        3) MC_VER="1.19.4" ;;
        4) MC_VER="1.18.2" ;;
        5) MC_VER="1.16.5" ;;
        6) read -p "Enter version: " MC_VER ;;
    esac
}

create_modpack() {
    select_loader
    select_minecraft_version

    mkdir -p "$MODPACK_DIR"

    read -p "Modpack name: " pack_name
    PACK_DIR="$MODPACK_DIR/$pack_name"

    mkdir -p "$PACK_DIR"/{mods,config,scripts,defaultconfigs}

    case $LOADER in
        fabric)
            FABRIC_VERSION=$(curl -s https://meta.fabricmc.net/v2/versions/loader/$MC_VER | jq -r '.[0].version')
            log "Fabric loader version: $FABRIC_VERSION"
            ;;
        forge)
            FORGE_VERSION=$(curl -s https://files.minecraftforge.net/maven/net/minecraftforge/forge/maven-metadata.json 2>/dev/null | jq -r '.versions[-1]' || echo "47.2.0")
            log "Forge version: $FORGE_VERSION"
            ;;
    esac

    log "Creating modpack: $pack_name"
    log "Directory: $PACK_DIR"
    success "Modpack directory created!"
    echo "Add mods to: $PACK_DIR/mods"
}

install_popular_mods() {
    PACK_NAME=${1:-default}
    PACK_DIR="$MODPACK_DIR/$PACK_NAME"
    mkdir -p "$PACK_DIR/mods"

    declare -A POPULAR_MODS=(
        ["Sodium"]="https://cdn.modrinth.com/data/AANobbMI/latest/files"
        ["Lithium"]="https://cdn.modrinth.com/data/gvQqBUqW/latest/files"
        ["FerriteCore"]="https://cdn.modrinth.com/data/uXXizFIs/latest/files"
        ["Indium"]="https://cdn.modrinth.com/data/32mDIBGc/latest/files"
        ["Iris"]="https://cdn.modrinth.com/data/ZeusdPcd/latest/files"
    )

    log "Installing popular performance mods..."

    for mod in "${!POPULAR_MODS[@]}"; do
        echo "  - $mod"
    done

    success "Mod list prepared"
    read -p "Use Modrinth API for download? (y/n): " use_api
    if [[ "$use_api" == "y" ]]; then
        log "Use 'mr' command: mr modid"
    fi
}

manage_modpack() {
    echo "=== Manage Modpacks ==="
    echo "Available modpacks:"
    ls -1 "$MODPACK_DIR" 2>/dev/null || echo "No modpacks found"

    read -p "Select modpack: " pack_name
    PACK_DIR="$MODPACK_DIR/$pack_name"

    if [ ! -d "$PACK_DIR" ]; then
        echo "Modpack not found"
        return
    fi

    echo "1) Add mods"
    echo "2) List mods"
    echo "3) Remove mods"
    echo "4) Backup modpack"
    echo "5) Export modpack"
    read -p "Choice: " choice

    case $choice in
        1) add_mods_to_pack "$PACK_DIR" ;;
        2) ls -lh "$PACK_DIR/mods" ;;
        3) remove_mods_from_pack "$PACK_DIR" ;;
        4) backup_modpack "$PACK_DIR" ;;
        5) export_modpack "$PACK_DIR" ;;
    esac
}

add_mods_to_pack() {
    local pack_dir=$1
    echo "Enter mod URLs (empty to finish):"
    while read -p "URL: " url && [ -n "$url" ]; do
        filename=$(basename "$url")
        curl -L -o "$pack_dir/mods/$filename" "$url" && \
            echo "  Downloaded: $filename" || \
            echo "  Failed: $filename"
    done
}

remove_mods_from_pack() {
    local pack_dir=$1
    ls -1 "$pack_dir/mods"
    read -p "Enter filename to remove: " filename
    rm -f "$pack_dir/mods/$filename" && echo "Removed" || echo "Not found"
}

backup_modpack() {
    local pack_dir=$1
    backup_name=$(basename "$pack_dir")_$(date +%Y%m%d).tar.gz
    tar -czf "$HOME/TermuxServerX/backups/$backup_name" -C "$MODPACK_DIR" "$(basename $pack_dir)"
    echo "Backup: $backup_name"
}

export_modpack() {
    local pack_dir=$1
    read -p "Export location: " export_dir
    mkdir -p "$export_dir"
    cp -r "$pack_dir" "$export_dir/"
    echo "Exported to: $export_dir/$(basename $pack_dir)"
}

show_help() {
    cat << EOF
=== Minecraft Modpack Manager ===

Usage: modpack-manager.sh <command>

Commands:
    create     - Create new modpack
    manage     - Manage existing modpack
    popular    - Install popular mods
    list       - List all modpacks
    help       - Show this help

Examples:
    ./modpack-manager.sh create
    ./modpack-manager.sh manage
    ./modpack-manager.sh popular

Supported Loaders: Fabric, Forge, Quilt, NeoForge
Supported Versions: 1.16.5 - 1.20.4
EOF
}

case "$1" in
    create) create_modpack ;;
    manage) manage_modpack ;;
    popular) install_popular_mods ;;
    list) ls -1 "$MODPACK_DIR" 2>/dev/null ;;
    help|--help|-h) show_help ;;
    *) show_help ;;
esac
