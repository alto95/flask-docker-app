#!/bin/bash

# Color definitions
MAGENTA='\033[1;35m'
GREEN='\033[1;32m'
RED='\033[1;31m'
NC='\033[0m'
CYAN='\033[1;36m'

LOG_FILE="/home/zen/flask-docker-app/startup.log"
CLOUDFLARE_LOG="/home/zen/flask-docker-app/cloudflared.log"

cd /home/zen/flask-docker-app/scripts || exit 1

echo -e "${MAGENTA}🚀 Launching full stack: App + Monitoring + Cloudflare...${NC}" | tee -a "$LOG_FILE"
echo | tee -a "$LOG_FILE"

# Step 1: Start Docker app
echo -e "${MAGENTA}🔧 Starting main Docker app stack...${NC}" | tee -a "$LOG_FILE"
./start-docker.sh >> "$LOG_FILE" 2>&1 || { echo -e "${RED}❌ Failed to start app stack. Exiting.${NC}" | tee -a "$LOG_FILE"; exit 1; }
echo | tee -a "$LOG_FILE"

# Step 2: Start monitoring stack
echo -e "${MAGENTA}📈 Starting monitoring stack...${NC}" | tee -a "$LOG_FILE"
./start-monitoring.sh >> "$LOG_FILE" 2>&1 || { echo -e "${RED}❌ Failed to start monitoring stack. Exiting.${NC}" | tee -a "$LOG_FILE"; exit 1; }
echo | tee -a "$LOG_FILE"

# Step 3: Start Cloudflare tunnel
echo -e "${MAGENTA}🌐 Starting Cloudflare tunnel...${NC}" | tee -a "$LOG_FILE"
./start-cloudflared.sh >> "$LOG_FILE" 2>&1 || { echo -e "${RED}❌ Failed to start Cloudflare tunnel. Exiting.${NC}" | tee -a "$LOG_FILE"; exit 1; }
echo | tee -a "$LOG_FILE"

# Step 4: Extract and show latest Cloudflare URL
TUNNEL_URL=$(tail -n 20 "$CLOUDFLARE_LOG" | grep -Eo 'https://[a-zA-Z0-9.-]+\.trycloudflare\.com' | tail -n 1)

if [ -n "$TUNNEL_URL" ]; then
  echo -e "${CYAN} 🌐 Tunnel URL: $TUNNEL_URL${NC}" | tee -a "$LOG_FILE"
else
  echo -e "${RED}⚠️  Tunnel started but URL not found in logs.${NC}" | tee -a "$LOG_FILE"
fi
echo | tee -a "$LOG_FILE"

echo -e "${GREEN}✅ All services started successfully!${NC}" | tee -a "$LOG_FILE"
echo -e "${MAGENTA}📄 Log saved to: $LOG_FILE${NC}"
echo -e "${MAGENTA}💡 View logs: tail -f $LOG_FILE${NC}"
