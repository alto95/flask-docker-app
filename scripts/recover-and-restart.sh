#!/bin/bash

MAGENTA='\033[1;35m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'

echo -e "${MAGENTA}🔄 Attempting to bring up the app stack...${NC}"
if ! docker-compose -f docker-compose.yml up -d --build; then
  echo -e "${RED}⚠️  Initial app stack start failed. Running recovery...${NC}"

  docker-compose -f docker-compose.yml down --remove-orphans
  docker volume prune -f
  docker network prune -f

  echo -e "${MAGENTA}🔄 Retrying app stack after cleanup...${NC}"
  docker-compose -f docker-compose.yml up -d --build

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ App stack recovered and running!${NC}"
  else
    echo -e "${RED}❌ App stack still failed after recovery. Check manually.${NC}"
    exit 1
  fi
else
  echo -e "${GREEN}✅ App stack started successfully on first try!${NC}"
fi

echo
echo -e "${MAGENTA}🔄 Attempting to bring up the monitoring stack...${NC}"
if ! docker-compose -f docker-compose.monitoring.yml up -d --build; then
  echo -e "${RED}⚠️  Monitoring stack start failed. Running recovery...${NC}"

  docker-compose -f docker-compose.monitoring.yml down --remove-orphans
  docker volume prune -f
  docker network prune -f

  echo -e "${MAGENTA}🔄 Retrying monitoring stack after cleanup...${NC}"
  docker-compose -f docker-compose.monitoring.yml up -d --build

  if [ $? -eq 0 ]; then
    echo -e "${GREEN}✅ Monitoring stack recovered and running!${NC}"
  else
    echo -e "${RED}❌ Monitoring stack still failed after recovery. Check manually.${NC}"
    exit 1
  fi
else
  echo -e "${GREEN}✅ Monitoring stack started successfully on first try!${NC}"
fi
