#!/bin/bash

# Color definitions
MAGENTA='\033[1;35m'  # Process steps
GREEN='\033[1;32m'    # Success
RED='\033[1;31m'      # Failure
NC='\033[0m'          # Reset

echo -e "${MAGENTA}🐳 Starting main application stack (frontend + backend + db)...${NC}"
echo

if docker compose -f /home/zen/flask-docker-app/docker-compose.yml up -d; then
  echo -e "${GREEN}✅ App containers started successfully.${NC}"
else
  echo -e "${RED}❌ Failed to start app containers.${NC}"
  exit 1
fi

echo

echo -e "${MAGENTA}📦 Running containers:${NC}"
docker ps --filter "name=flask-docker-app"
echo

echo -e "${MAGENTA}💡 To view logs: docker-compose -f docker-compose.yml logs -f${NC}"
echo
