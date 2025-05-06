#!/bin/bash

# Color definitions
MAGENTA='\033[1;35m'  # Process steps
GREEN='\033[1;32m'    # Success
RED='\033[1;31m'      # Failure
CYAN='\033[1;36m'     # Output
NC='\033[0m'          # Reset

LOG_PATH="/home/zen/flask-docker-app/cloudflared.log"

echo -e "${MAGENTA}🔄 Waiting for localhost:80 to respond...${NC}"
echo

until curl -s http://localhost:80 > /dev/null; do
  echo -e "${RED}  🚫 Not ready yet...${NC}"
  sleep 2
done

echo -e "${GREEN}✅ Frontend is ready.${NC}"
echo

echo -e "${MAGENTA}🚀 Starting Cloudflare tunnel...${NC}"
nohup cloudflared tunnel --url http://localhost:80 > "$LOG_PATH" 2>&1 &
sleep 10
echo

TUNNEL_URL=$(tail -n 20 "$LOG_PATH" | grep -Eo 'https://[a-zA-Z0-9.-]+\.trycloudflare\.com')

if [[ -n "$TUNNEL_URL" ]]; then
  echo -e "${CYAN}🌐 Tunnel URL: $TUNNEL_URL${NC}"
  echo
  echo -e "${GREEN}✅ Cloudflared started successfully.${NC}"
else
  echo -e "${RED}❌ Tunnel URL not found. Check logs at: $LOG_PATH${NC}"
fi

echo
