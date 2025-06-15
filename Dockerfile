FROM docker.n8n.io/n8nio/n8n:latest

# Switch to node user
USER node

# Copy the environment configuration
COPY .env /home/node/.n8n/.env

# The n8n image comes with everything we need
# No additional configuration needed as we're using SQLite with volumes 