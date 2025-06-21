FROM docker.n8n.io/n8nio/n8n:latest

# Copy entrypoint script with executable permissions
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# The n8n image comes with everything we need
# Environment variables will be set via Fly.io

# Start as root to handle backup operations, then switch to node user
# Use custom entrypoint to capture env vars at runtime
ENTRYPOINT ["/entrypoint.sh"]
CMD ["n8n"] 