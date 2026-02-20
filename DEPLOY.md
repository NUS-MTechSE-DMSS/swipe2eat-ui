# Railway Deployment Guide for Swipe2Eat UI

This guide explains how to deploy the Flutter web application to Railway.

## Table of Contents

- [Overview](#overview)
- [Prerequisites](#prerequisites)
- [Quick Start](#quick-start)
- [Configuration](#configuration)
- [Deployment Options](#deployment-options)
- [Monitoring & Logs](#monitoring--logs)
- [Troubleshooting](#troubleshooting)

## Overview

**Swipe2Eat UI** is a Flutter web application that is deployed as a containerized web service on Railway. The deployment consists of:

- **Dockerfile.railway**: Multi-stage build optimized for minimal image size
- **railway.json**: Railway platform configuration
- **nginx.conf.railway**: Advanced nginx config with caching, compression, and security headers
- **pubspec.yaml**: Flutter/Dart dependencies

### Architecture

```
┌─────────────────────┐
│   Railway Platform  │
├─────────────────────┤
│  Nginx 1.27-Alpine  │  <- HTTP Server (port 80)
├─────────────────────┤
│ Flutter Web Assets  │  <- Built web application
└─────────────────────┘
```

## Prerequisites

### Local Development

- Flutter SDK (^3.10.7)
- Dart SDK (included with Flutter)
- Docker (for local testing)
- Git

### Railway Account

1. Create a free account at [railway.app](https://railway.app)
2. Connect your GitHub repository
3. Have a Railway API token (optional, for CLI deployments)

## Quick Start

### Option 1: Railway Dashboard (Recommended for Beginners)

1. **Connect GitHub Repository**
   - Log in to Railway dashboard
   - Click "New Project" → "Deploy from GitHub"
   - Select the `swipe2eat-ui` repository
   - Click "Deploy"

2. **Configure Dockerfile**
   - In Railway project settings, set the Dockerfile path to: `Dockerfile.railway`
   - Set the port to `80`

3. **Deploy**
   - Railway will automatically detect, build, and deploy
   - Your app will be available at `https://<your-project-name>.railway.app`

### Option 2: Railway CLI

```bash
# Install Railway CLI
npm install -g @railway/cli

# Login to Railway
railway login

# Create a new project
railway init

# Deploy
railway up

# View logs
railway logs
```

### Option 3: Docker Compose (Local Testing)

```bash
# Build locally
docker build -f Dockerfile.railway -t swipe2eat-ui:latest .

# Run locally
docker run -p 8080:80 swipe2eat-ui:latest

# Visit http://localhost:8080
```

## Configuration

### Environment Variables

Set these in Railway dashboard under "Variables":

```env
# Optional: Override Flutter version (default: 3.38.8)
FLUTTER_VERSION=3.38.8

# Optional: Enable debug output
DEBUG=false
```

### Custom Domain

1. In Railway dashboard, go to your project settings
2. Add a custom domain (e.g., `swipe2eat.example.com`)
3. Configure DNS records as per Railway instructions

### Performance Tuning

**Nginx Configuration** (`nginx.conf.railway`):
- Gzip compression enabled for CSS, JS, JSON
- Long-term caching for versioned assets (30 days)
- 1-hour cache for service worker and manifests
- No cache for `index.html` (ensures fresh app on reload)

**Docker Image Optimization**:
- Multi-stage build reduces final image size by ~80%
- Alpine-based nginx keeps runtime lightweight
- Non-root user execution for security

## Deployment Options

### Standard Deployment (Current)

Uses `Dockerfile.railway` with:
- Ubuntu 22.04 as build base
- Nginx 1.27-Alpine as runtime
- Build time: ~5-10 minutes (first build), ~2-5 minutes (cached)
- Image size: ~150-200MB final image

### Alternative: Lighter Build (Optional)

If you want an even faster build, use the original `Dockerfile`:
```bash
# Update railway.json to use original Dockerfile
{
  "build": {
    "builder": "DOCKERFILE",
    "dockerfilePath": "Dockerfile"
  }
}
```

## Monitoring & Logs

### View Deployment Logs

**Railway Dashboard:**
```
Project → Deployments → [Your Deployment] → Logs
```

**Railway CLI:**
```bash
railway logs -f  # Follow logs in real-time
```

### Health Checks

Railway automatically checks the health of your deployment:
- **Endpoint**: `GET /index.html`
- **Interval**: Every 30 seconds
- **Timeout**: 5 seconds
- **Retries**: 3 attempts before marking unhealthy

### Common Log Messages

```
# Healthy deployment
2026-02-20 10:15:23 | nginx: [master process] start
2026-02-20 10:15:23 | [200] GET /index.html HTTP/1.1
```

```
# Build in progress
2026-02-20 10:10:00 | Building Flutter web...
2026-02-20 10:12:30 | Build complete! Output: 45.2 MB
```

## Troubleshooting

### Issue: Deployment Fails with "Dockerfile not found"

**Solution**: Verify `Dockerfile.railway` exists in the root directory:
```bash
ls -la Dockerfile.railway
```

Update `railway.json` if needed:
```json
{
  "build": {
    "dockerfilePath": "./Dockerfile.railway"
  }
}
```

### Issue: App Shows 404 or Blank Page

**Solution**: Ensure nginx is serving `index.html` correctly:
```bash
# Check nginx config is copied correctly
docker run -it swipe2eat-ui:latest cat /etc/nginx/conf.d/default.conf
```

Verify your `nginx.conf.railway` has the correct SPA routing:
```nginx
location / {
  try_files $uri $uri/ /index.html;
}
```

### Issue: Build Takes Too Long

**Solution**: 
- First builds (5-10 min) are slower due to Flutter SDK download
- Subsequent builds (2-5 min) use cached layers
- Check if build logs show asset processing delays

**Optimization**:
```dockerfile
# In Dockerfile.railway, reduce optional features
RUN flutter config --enable-web  # Essential only
# Remove: --no-tree-shake-icons if not needed
```

### Issue: Memory or CPU Exceeded

**Solution**: Adjust Railway plan or optimize build:
```dockerfile
# Reduce parallelism in build
RUN flutter build web --release --jobs=2
```

### Issue: CORS Errors When Calling External APIs

**Solution**: Configure CORS in your Flutter app or use an API gateway. Example:
```nginx
# In nginx.conf.railway, add CORS headers:
add_header 'Access-Control-Allow-Origin' '*' always;
add_header 'Access-Control-Allow-Methods' 'GET, OPTIONS' always;
```

### Issue: Unable to Connect to Backend API

**Solution**: 
1. Check API endpoint in your Flutter code
2. Verify API is reachable from Railway infrastructure
3. Add environment variables for API URL:

```json
// In railway.json or Railway dashboard:
{
  "deploy": {
    "env": {
      "API_BASE_URL": "https://api.example.com"
    }
  }
}
```

## File Structure

```
swipe2eat_ui/
├── Dockerfile              # Original build config
├── Dockerfile.railway      # Railway-optimized config
├── nginx.conf              # Original nginx config
├── nginx.conf.railway      # Enhanced nginx config
├── railway.json            # Railway platform config
├── DEPLOY.md               # This file
├── pubspec.yaml            # Flutter dependencies
├── pubspec.lock            # Locked dependency versions
├── lib/                    # Flutter source code
├── web/                    # Web-specific assets
│   ├── index.html
│   ├── manifest.json
│   └── favicon.png
└── build/                  # Build output (generated)
    └── web/               # Compiled Flutter web app
```

## Next Steps

1. ✅ Deploy the application to Railway
2. 🔗 Add a custom domain
3. 📊 Set up monitoring and error tracking
4. 🔐 Configure authentication if needed
5. 🚀 Set up CI/CD for automatic deployments

## Support & Resources

- **Railway Docs**: https://docs.railway.app
- **Flutter Web**: https://flutter.dev/docs/get-started/web
- **Nginx Docs**: https://nginx.org/en/docs/
- **Docker Docs**: https://docs.docker.com

---

**Last Updated**: February 2026
**Flutter Version**: 3.38.8
**Nginx Version**: 1.27-Alpine
