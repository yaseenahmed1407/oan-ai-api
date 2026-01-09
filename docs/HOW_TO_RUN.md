# How to Run Your OAN AI API

## 🎯 Quick Start (Currently Running!)

Your API is **already running** at:
- **API**: http://localhost:8000
- **Interactive Docs**: http://localhost:8000/docs
- **ReDoc**: http://localhost:8000/redoc

---

## 🚀 Method 1: Local Development (Python - No Docker)

**Best for**: Development, testing, debugging

### Start the API
```powershell
# Activate virtual environment and start server
.\venv\Scripts\Activate.ps1
uvicorn main:app --host 0.0.0.0 --port 8000 --reload
```

### What You Get
- ✅ Fast startup
- ✅ Auto-reload on code changes
- ✅ Easy debugging
- ❌ No Redis, Nominatim, or Marqo (unless installed separately)

### Stop the API
Press `Ctrl+C` in the terminal

---

## 🐳 Method 2: Docker Compose (Full Stack)

**Best for**: Production-like environment with all services

### Prerequisites
- Docker Desktop installed and running

### Start All Services
```powershell
# Start in detached mode (background)
docker compose up -d

# Or start with logs visible
docker compose up
```

### What You Get
- ✅ FastAPI app
- ✅ Redis (caching)
- ✅ Nominatim (geocoding)
- ✅ Marqo (vector search)
- ✅ All services networked together

### Service URLs
- **FastAPI**: http://localhost:8000
- **Redis**: http://localhost:6379
- **Redis Insight**: http://localhost:8001
- **Nominatim**: http://localhost:8080
- **Marqo**: http://localhost:8882

### Useful Commands
```powershell
# View logs
docker compose logs -f

# View logs for specific service
docker compose logs -f app

# Stop all services
docker compose down

# Stop and remove volumes (fresh start)
docker compose down -v

# Rebuild and start
docker compose up --build -d

# Check running containers
docker ps
```

---

## 🌐 Method 3: Pull from Docker Hub (Your Published Image)

**Best for**: Deploying the latest version from Docker Hub

### Pull and Run
```powershell
# Pull the latest image
docker pull yaseen1407/oan-ai-api:latest

# Run the container
docker run -d \
  --name oan-api \
  -p 8000:8000 \
  --env-file .env \
  yaseen1407/oan-ai-api:latest
```

### Stop the Container
```powershell
docker stop oan-api
docker rm oan-api
```

---

## 🔧 Method 4: Production Mode (Gunicorn)

**Best for**: Production deployment with multiple workers

### Start with Gunicorn
```powershell
.\venv\Scripts\Activate.ps1
gunicorn main:app --workers 4 --worker-class uvicorn.workers.UvicornWorker --bind 0.0.0.0:8000
```

### What You Get
- ✅ Multiple worker processes
- ✅ Better performance under load
- ✅ Automatic worker restart on failure
- ❌ No auto-reload (for production)

---

## 📊 Testing Your API

### 1. Open Interactive Docs
Go to: http://localhost:8000/docs

You'll see all your API endpoints with a "Try it out" button.

### 2. Test with cURL
```powershell
# Health check
curl http://localhost:8000/

# Example API call (adjust endpoint as needed)
curl http://localhost:8000/api/v1/your-endpoint
```

### 3. Test with Python
```python
import requests

response = requests.get("http://localhost:8000/")
print(response.json())
```

---

## 🛠️ Environment Configuration

### Required: .env File
Make sure you have a `.env` file with your configuration:

```bash
# Copy from example
cp .env.example .env

# Edit with your values
notepad .env
```

### Key Environment Variables
- `OPENAI_API_KEY`: Your OpenAI API key
- `REDIS_URL`: Redis connection URL
- `DATABASE_URL`: Database connection string (if using)
- `MARQO_URL`: Marqo service URL
- `NOMINATIM_URL`: Nominatim service URL

---

## 🐛 Troubleshooting

### Port Already in Use
```powershell
# Find what's using port 8000
netstat -ano | findstr :8000

# Kill the process (replace PID with actual process ID)
taskkill /PID <PID> /F
```

### Virtual Environment Issues
```powershell
# Recreate virtual environment
rm -r venv
python -m venv venv
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt
```

### Docker Issues
```powershell
# Restart Docker Desktop
# Then try again

# Clean up Docker
docker system prune -a
docker compose down -v
docker compose up --build
```

### Missing Dependencies
```powershell
# Reinstall dependencies
.\venv\Scripts\Activate.ps1
pip install -r requirements.txt --upgrade
```

---

## 📈 Performance Tips

### For Development
- Use `--reload` flag for auto-reload
- Run only the services you need
- Use local Python instead of Docker for faster iteration

### For Production
- Use Docker Compose for full stack
- Use Gunicorn with multiple workers
- Enable caching with Redis
- Monitor with logs: `docker compose logs -f`

---

## 🎓 Next Steps

1. **Test Your API**: Go to http://localhost:8000/docs
2. **Make Changes**: Edit your code and see it reload automatically
3. **Add Features**: Implement new endpoints
4. **Deploy**: Use Docker Compose for production
5. **Monitor**: Check logs and performance

---

## 📞 Quick Reference

| Command | Purpose |
|---------|---------|
| `uvicorn main:app --reload` | Start dev server |
| `docker compose up -d` | Start all services |
| `docker compose logs -f` | View logs |
| `docker compose down` | Stop all services |
| `Ctrl+C` | Stop local server |
| http://localhost:8000/docs | Interactive API docs |

---

**Your API is currently running at: http://localhost:8000** 🚀

Open http://localhost:8000/docs in your browser to start testing!
