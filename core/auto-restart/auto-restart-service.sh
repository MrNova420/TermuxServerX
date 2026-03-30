#!/data/data/com.termux/files/usr/bin/bash
# Service-specific auto-restart scripts
# Each service gets its own watcher

SERVICE_NAME="${0##*/auto-restart-}"
INSTALL_DIR="$HOME/TermuxServerX"

case "$SERVICE_NAME" in
    nginx)
        pgrep -x nginx >/dev/null && exit 0
        ~/TermuxServerX/services/web/nginx.sh start 2>/dev/null || nginx
        ;;
    php)
        pgrep -f "php-fpm" >/dev/null && exit 0
        ~/TermuxServerX/services/web/php.sh start 2>/dev/null || php-fpm
        ;;
    mariadb)
        pgrep -x mariadbd >/dev/null && exit 0
        ~/TermuxServerX/services/database/mariadb.sh start 2>/dev/null || mariadbd --user=$USER
        ;;
    postgresql)
        pgrep -f "postgres" >/dev/null && exit 0
        ~/TermuxServerX/services/database/postgresql.sh start 2>/dev/null || pg_ctl start -D ~/postgres_data
        ;;
    redis)
        pgrep -x redis-server >/dev/null && exit 0
        ~/TermuxServerX/services/database/redis.sh start 2>/dev/null || redis-server
        ;;
    jellyfin)
        pgrep -f jellyfin >/dev/null && exit 0
        screen -dmS jellyfin jellyfin
        ;;
    minecraft)
        screen -list | grep -q minecraft && exit 0
        screen -dmS minecraft ~/TermuxServerX/data/minecraft/start.sh
        ;;
    valheim)
        screen -list | grep -q valheim && exit 0
        screen -dmS valheim ~/TermuxServerX/data/valheim/start-server.sh
        ;;
    *)
        echo "Unknown service: $SERVICE_NAME"
        exit 1
        ;;
esac
