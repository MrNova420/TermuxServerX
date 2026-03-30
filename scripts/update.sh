#!/bin/bash
set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

TSX_DIR="$HOME/TermuxServerX"
GIT_REPO="${GIT_REPO:-https://github.com/termuxserverx/termuxserverx}"
CURRENT_VERSION=$(grep "TSX_VERSION" "$TSX_DIR/config.env" 2>/dev/null | cut -d'"' -f2 || echo "unknown")

log_info() { echo -e "${GREEN}[INFO]${NC} $1"; }
log_warn() { echo -e "${YELLOW}[WARN]${NC} $1"; }
log_error() { echo -e "${RED}[ERROR]${NC} $1"; }

check_for_updates() {
    log_info "Checking for updates..."
    log_info "Current version: $CURRENT_VERSION"
    
    if [ -d "$TSX_DIR/.git" ]; then
        cd "$TSX_DIR"
        git remote update 2>/dev/null || true
        LOCAL=$(git rev-parse HEAD)
        REMOTE=$(git rev-parse @{u} 2>/dev/null || echo "$LOCAL")
        
        if [ "$LOCAL" != "$REMOTE" ]; then
            log_info "Updates available!"
            echo ""
            git log --oneline HEAD..@{u} 2>/dev/null | head -5
            return 0
        else
            log_info "You are running the latest version"
            return 1
        fi
    else
        log_warn "Not a git repository, cannot check for updates"
        return 1
    fi
}

update_termuxserverx() {
    log_info "Updating TermuxServerX..."
    
    if [ ! -d "$TSX_DIR/.git" ]; then
        log_error "Not a git repository. Cannot update."
        log_info "To enable updates, reinstall with git or clone the repo"
        return 1
    fi
    
    cd "$TSX_DIR"
    
    log_info "Stashing current changes..."
    git stash 2>/dev/null || true
    
    log_info "Pulling latest changes..."
    git pull origin main 2>/dev/null || git pull 2>/dev/null || {
        log_error "Failed to pull updates"
        return 1
    }
    
    log_info "Applying optimizations..."
    bash "$TSX_DIR/core/optimize.sh" 2>/dev/null || true
    
    log_info "Update complete!"
}

update_packages() {
    log_info "Updating Termux packages..."
    
    pkg update -y
    pkg upgrade -y
    
    log_success "Packages updated"
}

update_service() {
    local service=$1
    
    log_info "Updating $service..."
    
    case $service in
        nginx)
            pkg upgrade -y nginx
            ;;
        php)
            pkg upgrade -y php php-fpm
            ;;
        mariadb)
            pkg upgrade -y mariadb
            ;;
        *)
            log_warn "Unknown service: $service"
            ;;
    esac
}

update_all_services() {
    log_info "Updating all services..."
    
    for service_dir in "$TSX_DIR/services"/*; do
        if [ -d "$service_dir" ]; then
            service=$(basename "$service_dir")
            
            if [ -f "$service_dir/update.sh" ]; then
                log_info "Updating $service..."
                bash "$service_dir/update.sh" 2>/dev/null || true
            fi
        fi
    done
    
    log_success "All services updated"
}

rollback() {
    log_info "Rolling back to previous version..."
    
    if [ ! -d "$TSX_DIR/.git" ]; then
        log_error "Not a git repository. Cannot rollback."
        return 1
    fi
    
    cd "$TSX_DIR"
    
    log_info "Reverting to previous commit..."
    git checkout HEAD~1 2>/dev/null || {
        log_error "Failed to rollback"
        return 1
    }
    
    log_success "Rolled back to previous version"
}

show_changelog() {
    if [ -d "$TSX_DIR/.git" ]; then
        cd "$TSX_DIR"
        log_info "Recent changes:"
        git log --oneline -10 2>/dev/null || true
    else
        log_warn "Not a git repository"
    fi
}

case "${1:-check}" in
    check)
        check_for_updates
        ;;
    update)
        check_for_updates && update_termuxserverx
        ;;
    force)
        update_termuxserverx
        ;;
    packages)
        update_packages
        ;;
    services)
        update_all_services
        ;;
    service)
        update_service "$2"
        ;;
    rollback)
        rollback
        ;;
    changelog)
        show_changelog
        ;;
    *)
        echo "Usage: $0 {check|update|force|packages|services|service <name>|rollback|changelog}"
        ;;
esac
