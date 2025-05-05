#!/bin/bash
echo "Cloudflare Tunnel URL:"
grep -i 'https://.*trycloudflare.com' /var/log/cloudflared.log | tail -1
