#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TSX_DIR="$HOME/TermuxServerX"
BACKUP_DIR="$TSX_DIR/backups"
DATE=$(date +%Y%m%d_%H%M%S)
BACKUP_NAME="tsx_backup_${DATE}"

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

create_backup_dir() {
    mkdir -p "$BACKUP_DIR/configs"
    mkdir -p "$BACKUP_DIR/databases"
    mkdir -p "$BACKUP_DIR/full"
}

backup_configs() {
    log_info "Backing up configurations..."
    
    local backup_file="$BACKUP_DIR/configs/configs_${DATE}.tar.gz"
    
    tar -czf "$backup_file" \
        -C "$TSX_DIR" \
        config.env \
        config/ \
        templates/ \
        2>/dev/null || true
    
    log_success "Configs backed up to: $backup_file"
    echo "$backup_file"
}

backup_databases() {
    log_info "Backing up databases..."
    
    local backup_file="$BACKUP_DIR/databases/databases_${DATE}.sql.gz"
    
    if is_service_running "mariadb"; then
        mysqldump --all-databases 2>/dev/null | gzip > "$backup_file"
        log_success "Databases backed up to: $backup_file"
    else
        log_warn "MariaDB not running, skipping database backup"
    fi
    
    echo "$backup_file"
}

backup_data() {
    log_info "Backing up service data..."
    
    local backup_file="$BACKUP_DIR/full/${BACKUP_NAME}.tar.gz"
    
    tar -czf "$backup_file" \
        -C "$TSX_DIR" \
        data/ \
        --exclude='data/minecraft/world*' \
        --exclude='data/minecraft/crash-reports' \
        --exclude='data/minecraft/logs' \
        2>/dev/null || true
    
    log_success "Data backed up to: $backup_file"
    echo "$backup_file"
}

backup_full() {
    log_info "Creating full backup..."
    
    create_backup_dir
    
    local full_backup="$BACKUP_DIR/full/full_backup_${DATE}.tar.gz"
    
    tar -czf "$full_backup" \
        -C "$TSX_DIR" \
        --exclude='data/minecraft/world*' \
        --exclude='data/minecraft/crash-reports' \
        --exclude='logs/*.log' \
        --exclude='backups' \
        . 2>/dev/null
    
    log_success "Full backup created: $full_backup"
    echo ""
    echo "Backup file: $full_backup"
    echo "Size: $(du -h "$full_backup" | cut -f1)"
    
    cleanup_old_backups
    
    echo "$full_backup"
}

backup_to_cloud() {
    local provider=$1
    local remote_path=$2
    
    log_info "Uploading backup to $provider..."
    
    if ! command -v rclone &>/dev/null; then
        log_warn "rclone not installed. Installing..."
        bash "$TSX_DIR/services/storage/rclone.sh" install
    fi
    
    local latest_backup=$(ls -t "$BACKUP_DIR/full"/*.tar.gz 2>/dev/null | head -1)
    
    if [ -z "$latest_backup" ]; then
        log_error "No backup found to upload"
        return 1
    fi
    
    rclone copy "$latest_backup" "$provider:$remote_path" --progress
    
    log_success "Backup uploaded to cloud"
}

cleanup_old_backups() {
    log_info "Cleaning up old backups..."
    
    local keep_days=${1:-7}
    
    find "$BACKUP_DIR" -name "*.tar.gz" -mtime +$keep_days -delete 2>/dev/null || true
    find "$BACKUP_DIR" -name "*.sql.gz" -mtime +$keep_days -delete 2>/dev/null || true
    
    log_success "Cleanup complete"
}

list_backups() {
    echo ""
    echo "=== Available Backups ==="
    echo ""
    
    if [ -d "$BACKUP_DIR/full" ]; then
        echo "Full Backups:"
        ls -lh "$BACKUP_DIR/full"/*.tar.gz 2>/dev/null | awk '{print "  "$9" ("$5")"}'
    fi
    
    if [ -d "$BACKUP_DIR/configs" ]; then
        echo ""
        echo "Config Backups:"
        ls -lh "$BACKUP_DIR/configs"/*.tar.gz 2>/dev/null | awk '{print "  "$9" ("$5")"}'
    fi
    
    if [ -d "$BACKUP_DIR/databases" ]; then
        echo ""
        echo "Database Backups:"
        ls -lh "$BACKUP_DIR/databases"/*.sql.gz 2>/dev/null | awk '{print "  "$9" ("$5")"}'
    fi
    
    echo ""
}

restore_config() {
    local backup_file=$1
    
    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: $backup_file"
        return 1
    fi
    
    log_info "Restoring configs from: $backup_file"
    
    tar -xzf "$backup_file" -C "$TSX_DIR"
    
    log_success "Configs restored"
}

restore_database() {
    local backup_file=$1
    
    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: $backup_file"
        return 1
    fi
    
    log_info "Restoring databases from: $backup_file"
    
    if ! is_service_running "mariadb"; then
        log_warn "MariaDB not running. Starting it first..."
        bash "$TSX_DIR/manage" start mariadb
        sleep 3
    fi
    
    gunzip < "$backup_file" | mysql
    
    log_success "Databases restored"
}

restore_full() {
    local backup_file=$1
    
    if [ ! -f "$backup_file" ]; then
        log_error "Backup file not found: $backup_file"
        return 1
    fi
    
    log_warn "This will restore ALL data. Services will be stopped."
    echo -n "Continue? (yes/no): "
    read confirm
    
    if [ "$confirm" != "yes" ]; then
        log_info "Restore cancelled"
        return 0
    fi
    
    log_info "Stopping all services..."
    bash "$TSX_DIR/manage" stop all 2>/dev/null || true
    
    log_info "Restoring full backup..."
    tar -xzf "$backup_file" -C "$TSX_DIR"
    
    log_info "Restarting services..."
    bash "$TSX_DIR/manage" start all 2>/dev/null || true
    
    log_success "Restore complete!"
}

case "${1:-create}" in
    create|backup)
        create_backup_dir
        backup_configs
        backup_databases
        backup_data
        backup_full
        ;;
    full)
        backup_full
        ;;
    configs)
        create_backup_dir
        backup_configs
        ;;
    databases)
        create_backup_dir
        backup_databases
        ;;
    cloud)
        backup_to_cloud "$2" "$3"
        ;;
    list)
        list_backups
        ;;
    cleanup)
        cleanup_old_backups "$2"
        ;;
    restore-config)
        restore_config "$2"
        ;;
    restore-database)
        restore_database "$2"
        ;;
    restore)
        restore_full "$2"
        ;;
    *)
        echo "Usage: $0 {create|full|configs|databases|cloud|list|cleanup|restore}"
        echo ""
        echo "Commands:"
        echo "  create           - Create full backup (configs + databases + data)"
        echo "  full             - Create full backup only"
        echo "  configs          - Backup configurations only"
        echo "  databases        - Backup databases only"
        echo "  cloud <provider> <path> - Upload latest backup to cloud"
        echo "  list             - List available backups"
        echo "  cleanup [days]   - Remove backups older than days (default: 7)"
        echo "  restore-config <file>   - Restore configurations"
        echo "  restore-database <file> - Restore databases"
        echo "  restore <file>   - Restore full backup"
        ;;
esac
