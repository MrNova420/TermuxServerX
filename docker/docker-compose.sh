#!/data/data/com.termux/files/usr/bin/bash
# Docker Compose Helper for TermuxServerX

INSTALL_DIR="$HOME/TermuxServerX"
DOCKER_DIR="$INSTALL_DIR/docker"

if ! command -v docker &>/dev/null; then
    echo "Docker not installed. Please install first."
    exit 1
fi

cd "$DOCKER_DIR"

case "$1" in
    up|start)
        echo "Starting all containers..."
        docker-compose up -d
        ;;
    down|stop)
        echo "Stopping all containers..."
        docker-compose down
        ;;
    restart)
        echo "Restarting all containers..."
        docker-compose restart
        ;;
    ps)
        docker-compose ps
        ;;
    logs)
        docker-compose logs -f "${2:-}"
        ;;
    pull)
        echo "Pulling latest images..."
        docker-compose pull
        ;;
    build)
        echo "Building images..."
        docker-compose build
        ;;
    clean)
        echo "Removing containers and volumes..."
        docker-compose down -v
        ;;
    *)
        echo "Usage: docker-compose.sh {up|down|restart|ps|logs|pull|build|clean}"
        ;;
esac
