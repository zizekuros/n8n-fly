FROM docker.n8n.io/n8nio/n8n:1.97.1

# Switch to node user
USER node

# The n8n image comes with everything we need
# Environment variables will be set via Fly.io 