#!/bin/sh

# Create backup directory
mkdir -p /home/node/.n8n/backup

# Create timestamped .env backup at runtime when Fly.io env vars are available
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
printenv > /home/node/data/.n8n/backup/${TIMESTAMP}.backup.env

# Start n8n
exec "$@"
