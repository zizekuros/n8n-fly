FROM docker.n8n.io/n8nio/n8n:latest

# Copy entrypoint script and set permissions as root
COPY entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh && chown node:node /entrypoint.sh

# Switch to node user
USER node

# The n8n image comes with everything we need
# Environment variables will be set via Fly.io

# Use custom entrypoint to capture env vars at runtime
ENTRYPOINT ["/entrypoint.sh"]
CMD ["n8n"] 