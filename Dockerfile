FROM docker.n8n.io/n8nio/n8n:latest

# Switch to node user
USER node

# The n8n image comes with everything we need
# Environment variables will be set via Fly.io 