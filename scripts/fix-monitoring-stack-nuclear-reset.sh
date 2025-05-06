#!/bin/bash

# Color setup
MAGENTA='\033[1;35m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

cd /home/zen/flask-docker-app || exit 1

echo -e "${MAGENTA}🧯 Fixing full monitoring stack (Grafana + Prometheus + Node Exporter)...${NC}"
echo

# Step 1: Stop & remove monitoring containers (safe cleanup only)
docker-compose -f docker-compose.monitoring.yml down --remove-orphans
echo -e "${GREEN}✅ Stopped and removed monitoring containers.${NC}"
echo

# Step 2: Clean Docker system (unused volumes, networks, etc.)
docker system prune -f --volumes
echo -e "${GREEN}✅ Pruned unused Docker data.${NC}"
echo

# Step 3: Rotate grafana/ volume if it exists
GRAFANA_DIR="monitoring/grafana"
if [ -d "$GRAFANA_DIR" ]; then
  BACKUP_NAME="monitoring/grafana_broken_$(date +%Y-%m-%d_%H-%M-%S)"
  mv "$GRAFANA_DIR" "$BACKUP_NAME"
  echo -e "${GREEN}📦 Archived old grafana/ to $BACKUP_NAME${NC}"
else
  echo -e "${MAGENTA}ℹ️  No existing grafana/ folder to archive.${NC}"
fi
echo

# Step 4: Recreate grafana directory with correct ownership
mkdir -p "$GRAFANA_DIR"
sudo chown 472:472 "$GRAFANA_DIR"
echo -e "${GREEN}✅ Created fresh grafana/ folder with UID 472 ownership.${NC}"
echo

echo -e "${MAGENTA}🎯 Now run start-monitoring.sh to bring services back online.${NC}"
echo

