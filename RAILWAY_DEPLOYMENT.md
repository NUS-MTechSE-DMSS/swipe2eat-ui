# 🚀 Railway Deployment Guide (All-in-One)

> **Status**: ✅ Production Ready | **Last Updated**: February 2026 | **Flutter Web**: 3.38.8

---

## 📋 Quick Start (3 Steps)


2. **Deploy**
   - Go to https://railway.app
   - Click "New Project" → "Deploy from GitHub"
   - Select your repo, click "Deploy"
3. **Wait & Access**
   - Build: 5-10 min (first), 2-5 min (cached)
   - App URL: `https://swipe2eat-ui-[random].railway.app`

---

## 🗂️ What’s Included

- **Dockerfile.railway**: Multi-stage Docker build (Ubuntu → Nginx)
- **railway.json**: Platform config (Dockerfile path, health check)
- **nginx.conf.railway**: SPA routing, gzip, security headers
- **.dockerignore.railway**: Build context optimization
- **DEPLOY.md**: Advanced/legacy deployment guide
- **.github/workflows/railway-deploy.yml**: (Optional) CI/CD

---

## 🏗️ File Guide

| File                     | Purpose                                 |
|--------------------------|-----------------------------------------|
| Dockerfile.railway       | Multi-stage build, optimized for Railway|
| railway.json             | Platform config, health checks          |
| nginx.conf.railway       | SPA routing, caching, security          |
| .dockerignore.railway    | Faster Docker builds                    |
| DEPLOY.md                | Advanced deployment guide               |

---

## 🛠️ Deployment Methods

- **Web Dashboard**: Easiest, click-through deploy
- **Railway CLI**: `npm install -g @railway/cli` → `railway up`
- **GitHub Actions**: Auto-deploy on push (see `.github/workflows/railway-deploy.yml`)

---

## 🧾 Verification Checklist

- [x] `Dockerfile.railway` exists and is valid
- [x] `railway.json` references correct Dockerfile
- [x] `nginx.conf.railway` has SPA routing (`try_files $uri $uri/ /index.html;`)
- [x] `.dockerignore.railway` present
- [x] All files committed and pushed
- [x] Health checks configured (GET /index.html)
- [x] Security headers in nginx config
- [x] Non-root user in Dockerfile

**Quick commands:**
```bash
ls -1 Dockerfile.railway railway.json nginx.conf.railway .dockerignore.railway
python3 -m json.tool railway.json
```

---

## 🛡️ Security & Performance

- Non-root user (`USER www-data`)
- Security headers: X-Frame-Options, CSP, etc.
- Gzip compression enabled
- Asset caching: 30d for assets, 1h for manifests, no-cache for index.html
- Health checks: `/index.html` every 30s
- Final image: ~150-200 MB

---

## 🐞 Troubleshooting

| Problem         | Solution                                      |
|----------------|-----------------------------------------------|
| Build fails    | Check Flutter version in Dockerfile.railway    |
| Blank page     | Verify SPA routing in nginx.conf.railway       |
| 404 errors     | Ensure `try_files` is set in nginx config      |
| Slow builds    | First build is slow; cached builds are faster  |
| Out of memory  | Upgrade Railway plan or reduce build jobs      |
| CORS errors    | Add CORS headers to nginx config               |
| API not found  | Check API URL env variable in Railway dashboard|

---

## 📈 Monitoring

- View logs in Railway dashboard or with `railway logs -f`
- Health checks: `/index.html` (should return 200)
- Metrics: CPU, memory, requests, error rate

---

## 🌐 Custom Domain

- Add in Railway dashboard → Project Settings → Domains
- Update DNS per Railway instructions
- SSL/TLS auto-provisioned

---

## 📚 Resources

- [Railway Docs](https://docs.railway.app)
- [Flutter Web Docs](https://flutter.dev/docs/get-started/web)
- [Nginx Docs](https://nginx.org/en/docs/)
- [Docker Docs](https://docs.docker.com/)

---

## ✅ Summary

You now have a **production-ready** Railway deployment setup for your Flutter web app. All configuration, security, and performance best practices are implemented. For advanced details, see `DEPLOY.md`.

**Ready?** Push to GitHub and deploy via Railway!

---

*Version: 1.0 | Last Updated: February 2026 | Status: ✅ Production Ready*
