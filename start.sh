#!/bin/bash

echo "=========================================="
echo "OAN AI API - Container Startup"
echo "=========================================="
echo "Python: $(python --version)"
echo "Working Dir: $(pwd)"
echo "Time: $(date)"
echo ""

echo "=========================================="
echo "Environment Variables"
echo "=========================================="
echo "LLM_PROVIDER: ${LLM_PROVIDER:-NOT_SET}"
echo "LLM_MODEL_NAME: ${LLM_MODEL_NAME:-NOT_SET}"
echo "GROQ_API_KEY: ${GROQ_API_KEY:0:20}..."
echo "PORT: ${PORT:-80}"
echo "ENVIRONMENT: ${ENVIRONMENT:-NOT_SET}"
echo ""

# Set defaults for missing env vars
export LLM_PROVIDER=${LLM_PROVIDER:-groq}
export LLM_MODEL_NAME=${LLM_MODEL_NAME:-llama-3.3-70b-versatile}
export ENVIRONMENT=${ENVIRONMENT:-production}
export USE_REDIS=${USE_REDIS:-false}

echo "=========================================="
echo "Python Package Verification"
echo "=========================================="
python3 -c "import fastapi; print('✅ FastAPI:', fastapi.__version__)"
python3 -c "import uvicorn; print('✅ Uvicorn:', uvicorn.__version__)"
python3 -c "import gunicorn; print('✅ Gunicorn installed')"
python3 -c "import tiktoken; print('✅ Tiktoken installed')"
python3 -c "import pydantic_ai; print('✅ Pydantic-AI installed')"
echo ""

echo "=========================================="
echo "Application Import Test"
echo "=========================================="

python3 << 'PYTHON_EOF'
import sys
import os

# Ensure env vars are set
os.environ.setdefault('LLM_PROVIDER', 'groq')
os.environ.setdefault('LLM_MODEL_NAME', 'llama-3.3-70b-versatile')
os.environ.setdefault('USE_REDIS', 'false')

try:
    print("Testing: helpers.utils")
    from helpers.utils import get_logger
    print("✅ helpers.utils")
    
    print("Testing: app.config")
    from app.config import settings
    print(f"✅ app.config (LLM: {settings.llm_provider})")
    
    print("Testing: app.core.cache")
    from app.core.cache import cache
    print("✅ app.core.cache")
    
    print("Testing: agents.models")
    from agents.models import LLM_MODEL
    print(f"✅ agents.models")
    
    print("Testing: app.routers")
    from app.routers import chat_router, suggestions_router
    from app.routers.health import router as health_router
    print("✅ app.routers")
    
    print("Testing: main app")
    from main import app
    print(f"✅ Main app: {app.title}")
    
    print("\n✅ All imports successful!")
    sys.exit(0)
    
except Exception as e:
    print(f"\n❌ Import failed: {e}")
    import traceback
    traceback.print_exc()
    print("\n⚠️  Attempting to start anyway (imports may succeed in Gunicorn context)...")
    sys.exit(0)  # Don't fail - let Gunicorn try

PYTHON_EOF

echo ""
echo "=========================================="
echo "Starting Gunicorn Server"
echo "=========================================="
echo "Binding to: 0.0.0.0:${PORT:-80}"
echo "Workers: 2"
echo "Worker Class: uvicorn.workers.UvicornWorker"
echo ""

# Start Gunicorn
exec gunicorn main:app \
    --workers 2 \
    --worker-class uvicorn.workers.UvicornWorker \
    --bind 0.0.0.0:${PORT:-80} \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    --log-level info \
    --capture-output \
    --enable-stdio-inheritance \
    --preload
