#!/bin/sh

# Create backup directory
mkdir -p /home/node/data/backup/env
chown -R node:node /home/node/data/backup

# Current timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# ENV backup
printenv > /home/node/data/backup/env/${TIMESTAMP}.backup.env
BACKUP_DIR="/home/node/data/backup/env"
BACKUP_COUNT=$(ls -1 ${BACKUP_DIR}/*.backup.env 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 10 ]; then
    ls -1 ${BACKUP_DIR}/*.backup.env 2>/dev/null | sort | head -n $((BACKUP_COUNT - 10)) | xargs rm -f
fi

# Set proper ownership for .n8n directory only (not lost+found)
chown -R node:node /home/node/data/.n8n
chown node:node /home/node/data

# Switch to node user and start n8n using su
exec su node -c "$*"
