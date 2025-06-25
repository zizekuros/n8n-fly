#!/bin/sh

# Backup configuration flags
BACKUP_ENV=true
BACKUP_CREDENTIALS=false
BACKUP_WORKFLOWS=false

# Create backup directories
mkdir -p /home/node/data/backup/env
mkdir -p /home/node/data/backup/workflows
mkdir -p /home/node/data/backup/credentials
chown -R node:node /home/node/data/backup

# Current timestamp
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")

# ENV backup
if [ "$BACKUP_ENV" = "true" ]; then
    echo "Creating environment backup..."
    printenv > /home/node/data/backup/env/${TIMESTAMP}.backup.env
    BACKUP_DIR="/home/node/data/backup/env"
    BACKUP_COUNT=$(ls -1 ${BACKUP_DIR}/*.backup.env 2>/dev/null | wc -l)
    if [ "$BACKUP_COUNT" -gt 10 ]; then
        ls -1 ${BACKUP_DIR}/*.backup.env 2>/dev/null | sort | head -n $((BACKUP_COUNT - 10)) | xargs rm -f
    fi
fi

# Set proper ownership for .n8n directory only (not lost+found)
chown -R node:node /home/node/data/.n8n
chown node:node /home/node/data

# Function to cleanup old backups in a directory
cleanup_backups() {
    local backup_dir="$1"
    local count=$(ls -1 ${backup_dir}/*.json 2>/dev/null | wc -l)
    if [ "$count" -gt 10 ]; then
        ls -1 ${backup_dir}/*.json 2>/dev/null | sort | head -n $((count - 10)) | xargs rm -f
    fi
}

# Check if we need to start n8n for exports
if [ "$BACKUP_WORKFLOWS" = "true" ] || [ "$BACKUP_CREDENTIALS" = "true" ]; then
    # Start n8n in background to allow exports
    echo "Starting n8n in background for data export..."
    su node -c "n8n start" &
    N8N_PID=$!

    # Wait for n8n to be ready (max 60 seconds)
    echo "Waiting for n8n to be ready..."
    for i in $(seq 1 60); do
        if su node -c "curl -s http://localhost:5678/healthz" >/dev/null 2>&1; then
            echo "n8n is ready!"
            break
        fi
        if [ $i -eq 60 ]; then
            echo "Warning: n8n did not become ready in 60 seconds, proceeding anyway..."
        fi
        sleep 1
    done

    # Export workflows if enabled
    if [ "$BACKUP_WORKFLOWS" = "true" ]; then
        echo "Exporting workflows..."
        su node -c "cd /home/node/data && n8n export:workflow --all --output=/home/node/data/backup/workflows/${TIMESTAMP}.workflows.json" 2>/dev/null || echo "No workflows to export or n8n not ready"
        cleanup_backups "/home/node/data/backup/workflows"
    fi

    # Export credentials if enabled
    if [ "$BACKUP_CREDENTIALS" = "true" ]; then
        echo "Exporting credentials..."
        su node -c "cd /home/node/data && n8n export:credentials --all --output=/home/node/data/backup/credentials/${TIMESTAMP}.credentials.json" 2>/dev/null || echo "No credentials to export or n8n not ready"
        cleanup_backups "/home/node/data/backup/credentials"
    fi

    # Stop background n8n
    kill $N8N_PID 2>/dev/null
    wait $N8N_PID 2>/dev/null
fi

# Now start n8n normally in foreground
echo "Starting n8n in foreground..."
exec su node -c "$*"
