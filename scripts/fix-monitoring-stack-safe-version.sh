#!/bin/bash

# Color setup
MAGENTA='\033[1;35m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

cd /home/zen/flask-docker-app || exit 1

echo -e "${MAGENTA}🧯 Fixing monitoring stack (Grafana only)...${NC}"
echo

# Step 1: Remove only Grafana container
docker container rm -f grafana 2>/dev/null && \
echo -e "${GREEN}✅ Removed old grafana container.${NC}" || \
echo -e "${MAGENTA}ℹ️  No existing grafana container to remove.${NC}"
echo

# Step 2: Archive grafana volume folder if it exists
GRAFANA_DIR="monitoring/grafana"
if [ -d "$GRAFANA_DIR" ]; then
  BACKUP_NAME="monitoring/grafana_broken_$(date +%Y-%m-%d_%H-%M-%S)"
  mv "$GRAFANA_DIR" "$BACKUP_NAME"
  echo -e "${GREEN}📦 Archived old grafana/ to $BACKUP_NAME${NC}"
else
  echo -e "${MAGENTA}ℹ️  No existing grafana/ folder to archive.${NC}"
fi
echo

# Step 3: Recreate grafana/ directory with correct permissions
mkdir -p "$GRAFANA_DIR"
sudo chown 472:472 "$GRAFANA_DIR"
echo -e "${GREEN}✅ Created fresh grafana/ with UID 472 ownership.${NC}"
echo

echo -e "${MAGENTA}🎯 Now run start-monitoring.sh to start clean.${NC}"
echo
