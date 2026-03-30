#!/bin/bash
# TermuxServerX - Ollama AI/LLM Installer (2026 Trend)
set -e

TSX_DIR="$HOME/TermuxServerX"
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m'
log() { echo -e "${GREEN}[INFO]${NC} $1"; }
warn() { echo -e "${RED}[WARN]${NC} $1"; }

install_ollama() {
    log "Installing Ollama (Self-hosted AI/LLM)..."
    
    warn "Ollama requires 4GB+ RAM for AI models"
    
    pkg update -y
    pkg install -y curl
    
    ARCH=$(uname -m)
    case "$ARCH" in
        aarch64|arm64) ARCH="arm64" ;;
        x86_64|amd64) ARCH="amd64" ;;
        *) warn "Unsupported architecture for Ollama"; return 1 ;;
    esac
    
    curl -fsSL https://ollama.ai/install.sh | sh
    
    log "Ollama installed!"
    echo ""
    echo "Commands:"
    echo "  ollama run llama3.2       # Run Llama 3.2 model"
    echo "  ollama run mistral         # Run Mistral model"
    echo "  ollama run codellama       # Code assistant"
    echo ""
    echo "API: http://localhost:11434"
}

pull_model() {
    local model=${1:-llama3.2}
    log "Pulling model: $model..."
    ollama pull "$model"
}

case "${1:-install}" in
    install) install_ollama ;;
    pull) pull_model "${2:-llama3.2}" ;;
    *) echo "Usage: $0 {install|pull [model]}" ;;
esac
