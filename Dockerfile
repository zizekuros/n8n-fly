FROM docker.n8n.io/n8nio/n8n:latest

# Copy entrypoint script with executable permissions
COPY --chmod=755 entrypoint.sh /entrypoint.sh

# Switch to node user
USER node

# The n8n image comes with everything we need
# Environment variables will be set via Fly.io

# Use custom entrypoint to capture env vars at runtime
ENTRYPOINT ["/entrypoint.sh"]
CMD ["n8n"] 