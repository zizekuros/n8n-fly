# n8n on Fly.io with Persistent Storage

This repository contains configuration for deploying n8n workflow automation tool on Fly.io using persistent volume storage. The setup uses SQLite with mounted volumes for data storage, which is suitable for personal or small team use. For production workloads with multiple instances or higher concurrency, using PostgreSQL is recommended.

## Overview

- Deploys n8n with persistent volume storage
- Uses SQLite database (stored on volume)
- Single volume mount with subdirectories for data and files
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
   fly volumes create n8n_data --size 1 --app $APP_NAME
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
   fly deploy --app $APP_NAME
   ```

6. **Add Custom Domain** (Optional)
   ```bash
   fly domains add $N8N_HOST --app $APP_NAME
   ```

## Security Note

The `N8N_ENCRYPTION_KEY` is required to encrypt sensitive workflow data. It's managed through Fly.io secrets and automatically made available to n8n - you don't need to add it to the `.env` file.

## Management Commands

### Pause Application
```bash
fly scale count 0 --app $APP_NAME
```

### Resume Application
```bash
fly scale count 1 --app $APP_NAME
```

### Restart Application
Re-deploy after changing the configuration.
```bash
fly deploy --app $APP_NAME
```

### Destroy All Resources
```bash
fly destroy $APP_NAME
```

## Monitoring

### View logs
```bash
fly logs --app $APP_NAME
```
### Check status
```bash
fly status --app $APP_NAME
```
### Access console
```bash
fly console --app $APP_NAME
```
### Check Mounted Volume Contents
```bash
# Connect to the machine
fly ssh console --app $APP_NAME

# Once connected, check the mounted volume contents
ls -la /data
ls -la /data/n8n
ls -la /data/files
```

## Notes

- This setup uses a Fly.io machine with 512MB RAM and 1 shared CPU
- Single volume (1GB) with subdirectories for:
  - `/data/n8n`: n8n configuration and SQLite database
  - `/data/files`: Shared files storage
- Your n8n instance will be available at `${APP_NAME}.fly.dev` by default
- For higher workloads, consider using PostgreSQL instead of SQLite
- Backup your volume regularly as it contains all your workflows and data

## Support

- [Fly.io Documentation](https://fly.io/docs/)
- [n8n Documentation](https://docs.n8n.io/)
