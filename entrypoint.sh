#!/bin/sh

# Create backup directory as root (skip lost+found)
mkdir -p /home/node/data/.n8n/backup

# Create timestamped .env backup at runtime when Fly.io env vars are available
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
printenv > /home/node/data/.n8n/backup/${TIMESTAMP}.backup.env

# Set proper ownership for .n8n directory only (not lost+found)
chown -R node:node /home/node/data/.n8n

# Switch to node user and start n8n using su
exec su node -c "$*"
