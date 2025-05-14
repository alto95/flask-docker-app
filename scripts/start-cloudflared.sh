#!/bin/bash

# === Safe defaults ===
RED='\033[0;31m'
GREEN='\033[0;32m'
MAGENTA='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

# Log file path
LOG_PATH="./cloudflared.log"

# Ensure log file exists and is clean
touch "$LOG_PATH"
truncate -s 0 "$LOG_PATH"

# === Wait for frontend to be ready ===
MAX_RETRIES=15
RETRY_COUNT=0

echo -e "${MAGENTA}🔄 Waiting for localhost:80 to respond...${NC}"
until curl -s http://localhost:80 > /dev/null || [[ $RETRY_COUNT -ge $MAX_RETRIES ]]; do
  echo -e "${RED}  🚫 Not ready yet...${NC}"
  sleep 2
  ((RETRY_COUNT++))
done

if [[ $RETRY_COUNT -ge $MAX_RETRIES ]]; then
  echo -e "${RED}❌ Frontend did not start after $((MAX_RETRIES * 2)) seconds. Exiting.${NC}"
  exit 1
fi

echo -e "${GREEN}✅ Frontend is ready.${NC}"
echo

# === Start Cloudflare Tunnel ===
echo -e "${MAGENTA}🚀 Starting Cloudflare tunnel...${NC}"
nohup cloudflared tunnel --url http://localhost:80 > "$LOG_PATH" 2>&1 &

sleep 2

# Verify cloudflared started
if ! pgrep -f "cloudflared tunnel" > /dev/null; then
  echo -e "${RED}❌ Cloudflared did not start. Check your setup.${NC}"
  exit 1
fi

# === Wait for Tunnel URL ===
MAX_TUNNEL_RETRIES=15
TUNNEL_RETRY_COUNT=0

until grep -qE 'https://[a-zA-Z0-9.-]+\.trycloudflare\.com' "$LOG_PATH" || [[ $TUNNEL_RETRY_COUNT -ge $MAX_TUNNEL_RETRIES ]]; do
  echo -e "${MAGENTA}⏳ Waiting for Cloudflare tunnel to be assigned...${NC}"
  sleep 2
  ((TUNNEL_RETRY_COUNT++))
done

TUNNEL_URL=$(grep -Eo 'https://[a-zA-Z0-9.-]+\.trycloudflare\.com' "$LOG_PATH" | tail -n 1)

if [[ -n "$TUNNEL_URL" ]]; then
  echo -e "${CYAN}🌐 Tunnel URL: $TUNNEL_URL${NC}"
  echo -e "${GREEN}✅ Cloudflared started successfully.${NC}"
else
  echo -e "${RED}❌ Tunnel URL not found after $((MAX_TUNNEL_RETRIES * 2)) seconds. Check logs at: $LOG_PATH${NC}"
  exit 1
fi

echo
