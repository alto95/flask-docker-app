#!/bin/bash

CYAN='\033[1;36m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m' # No Color

echo -e "${CYAN}🐳 Starting main application stack (frontend + backend + db)...${NC}"
if docker-compose -f /home/zen/flask-docker-app/docker-compose.yml up -d; then
  echo -e "${GREEN}✅ App containers started successfully.${NC}"
else
  echo -e "${RED}❌ Failed to start app containers.${NC}"
  exit 1
fi

echo -e "${CYAN}📦 Running containers:${NC}"
docker ps --filter "name=flask-docker-app"

echo -e "${CYAN}💡 To view logs: ${NC}docker-compose -f docker-compose.yml logs -f"
