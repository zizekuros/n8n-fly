FROM docker.n8n.io/n8nio/n8n:1.97.1

# Ensure we start as root for setup operations
USER root

# Copy entrypoint script with executable permissions
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# Create necessary directories as root
RUN mkdir -p /home/node/data/.n8n

# The entrypoint will handle switching to node user
# Environment variables will be set via Fly.io

# Use custom entrypoint to capture env vars at runtime
ENTRYPOINT ["/entrypoint.sh"]
CMD ["n8n"] 