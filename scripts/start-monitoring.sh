#!/bin/bash

# Color definitions
MAGENTA='\033[1;35m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

# Set working directory
APP_DIR="/home/zen/flask-docker-app"
cd "$APP_DIR" || { echo -e "${RED}❌ Failed to cd into $APP_DIR. Exiting.${NC}"; exit 1; }

echo -e "${MAGENTA}🛡️  Checking Grafana volume permissions...${NC}"
echo

# Check Grafana volume if it's a host-mounted directory (only if using one)
GRAFANA_DIR="$APP_DIR/monitoring/grafana"
DB_PATH="$GRAFANA_DIR/grafana.db"

if [ -f "$DB_PATH" ]; then
    OWNER_UID=$(stat -c "%u" "$DB_PATH" 2>/dev/null || echo 0)
    if [ "$OWNER_UID" -ne 472 ]; then
        echo -e "${RED}⚠️  grafana.db is not owned by UID 472. Resetting local grafana folder...${NC}"
        BACKUP_NAME="$APP_DIR/monitoring/grafana_$(date +%Y-%m-%d_%H-%M-%S)"
        mv "$GRAFANA_DIR" "$BACKUP_NAME"
        mkdir -p "$GRAFANA_DIR"
        sudo chown 472:472 "$GRAFANA_DIR"
        echo -e "${GREEN}✅ Fresh grafana directory created. Backup saved as: $BACKUP_NAME${NC}"
    else
        echo -e "${GREEN}✅ grafana.db ownership OK (UID 472).${NC}"
    fi
else
    echo -e "${GREEN}ℹ️  grafana.db not found — assuming Docker volume use (no action needed).${NC}"
fi

echo
echo -e "${MAGENTA}🧹 Cleaning up old containers and volumes...${NC}"
docker compose -f docker-compose.monitoring.yml down -v --remove-orphans

echo
echo -e "${MAGENTA}🚀 Starting monitoring stack (Prometheus, Grafana, Loki)...${NC}"
if docker compose -f docker-compose.monitoring.yml up -d; then
    echo -e "${GREEN}✅ Monitoring containers started successfully.${NC}"
else
    echo -e "${RED}❌ Failed to start monitoring containers. Check logs!${NC}"
    exit 1
fi

echo
echo -e "${MAGENTA}📦 Running monitoring containers:${NC}"
docker ps --filter "name=prometheus"
docker ps --filter "name=grafana"
docker ps --filter "name=loki"
echo

echo -e "${MAGENTA}💡 To follow logs live: docker compose -f docker-compose.monitoring.yml logs -f${NC}"
echo
