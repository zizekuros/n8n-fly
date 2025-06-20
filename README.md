# n8n on Fly.io with Persistent Storage

This repository contains configuration for deploying n8n workflow automation tool on Fly.io using persistent volume storage. The setup uses SQLite with mounted volumes for data storage, which is suitable for personal or small team use. For production workloads with multiple instances or higher concurrency, using PostgreSQL is recommended.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Deployment Steps](#deployment-steps)
- [Security Note](#security-note)
- [Updating the Application](#updating-the-application)
- [Notes](#notes)
- [Support](#support)

## Overview

- Deploys n8n with persistent volume storage (both in Fra region)
- Uses SQLite database (stored on volume)
- Automatic HTTPS/SSL certificate management
- Custom domain support (default: `<app-name>.fly.dev`)
- Secure encryption key management using Fly.io secrets

## Prerequisites

1. **Fly.io Account**
   - Sign up at [fly.io](https://fly.io)
   - Add a payment method

2. **Required Tools**
   - Fly CLI (`flyctl`) - [Installation Guide](https://fly.io/docs/hands-on/install-flyctl/)

3. **Domain Name** (optional)
   - By default, your app will be available at `<app-name>.fly.dev`
   - You can optionally use your own domain instead

## Deployment Steps

1. **Clone and Configure**
   
   Clone this repository first and move into the folder.
   ```bash
   git clone https://github.com/zizekuros/n8n-fly
   cd n8n-fly
   ```
   
   Copy example environment file.
   ```bash
   cp example.env .env
   ```
   Edit .env file to set your application name. Replace ${APP_NAME} with your desired name (e.g., "my-n8n-app")
   ```bash
   nano .env
   ```   
   Set the APP_NAME variable in your shell.
   ```bash
   export APP_NAME="your-n8n-app-name"
   ```
   Load all environment variables.
   ```bash
   source .env
   ```

2. **Create Application**

   Initialize Fly.io application.
   ```bash
   fly apps create $APP_NAME
   ```

3. **Create Volume**
   
   Create a single volume with 1GB size.
   ```bash
   fly volumes create n8n_data --size 1 --region fra --app $APP_NAME
   ```

4. **Set Up Encryption Key**

   Generate a secure encryption key.
   ```bash
   ENCRYPTION_KEY=$(openssl rand -base64 32)
   ```
   Store the encryption key in Fly.io secrets. This will be automatically available to n8n as environmental variable.
   ```bash
   fly secrets set N8N_ENCRYPTION_KEY="$ENCRYPTION_KEY" --app $APP_NAME
   ```

5. **Deploy application**
   ```bash
   fly deploy --app $APP_NAME --no-cache
   ```

6. **Add Custom Domain** (Optional)
   
   Create a certificate for your custom domain:
   ```bash
   fly certs add $N8N_HOST --app $APP_NAME
   ```
   
   Follow the DNS validation instructions displayed in the Fly.io dashboard under **Certificates** to configure your DNS records (A/AAAA or CNAME).
   
   Update your `.env` file to set `N8N_HOST`, `N8N_EDITOR_BASE_URL` and `WEEBHOOK_URL` to your custom domain (not the default `.fly.dev` domain), for example:
   ```bash
   N8N_HOST=https://your-domain.com
   N8N_EDITOR_BASE_URL=https://your-domain.com
   WEBHOOK_URL=https://your-domain.com
   ```
   
   Re-deploy the application to apply the changes:
   ```bash
   fly deploy --app $APP_NAME --no-cache
   ```

## Security Note

The `N8N_ENCRYPTION_KEY` is required to encrypt sensitive workflow data. It's managed through Fly.io secrets and automatically made available to n8n - you don't need to add it to the `.env` file.

## Updating the Application

**⚠️ Important**: n8n does not update automatically. To get the latest version, you must redeploy your application.

### GitHub Actions Deployment (Recommended)

1. **Create Fly.io API token**:
   ```bash
   fly tokens create deploy
   ```
   Copy the generated token.

2. **Set up repository secrets** in your GitHub repository (**Settings** → **Secrets and variables** → **Actions**):

   - `FLY_API_TOKEN` - Your Fly.io API token (from step 1)
   - `FLY_APP_NAME` - Your application name (e.g., "my-n8n-app") 
   - `FLY_APP_ENV` - Your complete `.env` file content

3. **Deploy manually**:
   
   Go to **Actions** tab in your GitHub repository, select **Fly Deploy** workflow, and click **Run workflow**.

### Manual Deployment

Update to the latest n8n version and redeploy:
```bash
fly deploy --app $APP_NAME --no-cache
```
## Notes

- This setup uses a Fly.io machine with 512MB RAM and 1 shared CPU
- Your n8n instance will be available at `${APP_NAME}.fly.dev` by default
- For higher workloads, consider using PostgreSQL instead of SQLite
- Backup your volume regularly as it contains all your workflows and data
- **⚠️ Running this setup will incur Fly.io costs** - monitor your usage and consider pausing when not needed

## Support

- [Fly.io Documentation](https://fly.io/docs/)
- [n8n Documentation](https://docs.n8n.io/)
