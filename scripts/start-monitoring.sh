#!/bin/bash

# Color definitions
MAGENTA='\033[1;35m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

cd /home/zen/flask-docker-app || exit 1

echo -e "${MAGENTA}🛡️  Checking Grafana volume permissions...${NC}"
echo

DB_PATH="grafana/grafana.db"
OWNER_UID=$(stat -c "%u" "$DB_PATH" 2>/dev/null || echo 0)

if [ "$OWNER_UID" -ne 472 ]; then
  echo -e "${RED}⚠️  grafana.db is not owned by UID 472. Resetting volume...${NC}"
  if [ -d "grafana" ]; then
    BACKUP_NAME="grafana_$(date +%Y-%m-%d_%H-%M-%S)"
    mv grafana "$BACKUP_NAME"
    echo -e "${GREEN}📦 Old grafana/ renamed to $BACKUP_NAME${NC}"
    echo
  fi

  mkdir grafana
  sudo chown 472:472 grafana
  echo -e "${GREEN}✅ Created fresh grafana/ with UID 472 ownership.${NC}"
  echo
else
  echo -e "${GREEN}✅ grafana.db already owned by UID 472. No reset needed.${NC}"
  echo
fi

echo -e "${MAGENTA}📊 Starting monitoring stack (Prometheus, Grafana, Node Exporter)...${NC}"
echo

if docker-compose -f docker-compose.monitoring.yml up -d; then
  echo -e "${GREEN}✅ Monitoring containers started successfully.${NC}"
else
  echo -e "${RED}❌ Failed to start monitoring containers.${NC}"
  exit 1
fi

echo

echo -e "${MAGENTA}📦 Running monitoring containers:${NC}"
docker ps --filter "name=prometheus"
docker ps --filter "name=grafana"
docker ps --filter "name=node-exporter"
echo

echo -e "${MAGENTA}💡 To view logs: docker-compose -f docker-compose.monitoring.yml logs -f${NC}"
echo
