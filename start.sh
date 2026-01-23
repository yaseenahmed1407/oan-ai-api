#!/bin/bash

# OAN AI API - Startup Script
# Optimized for Azure Functions (Custom Container)

set -e

echo "=========================================="
echo "🚀 OAN AI API - Starting Up"
echo "=========================================="
echo "Python Version: $(python3 --version)"
echo "Current Directory: $(pwd)"
echo "Timestamp: $(date)"
echo ""

# Export default environment variables
export PORT=${PORT:-80}
export WEBSITES_PORT=${WEBSITES_PORT:-$PORT}
export ENVIRONMENT=${ENVIRONMENT:-production}

echo "=========================================="
echo "📡 Port Configuration"
echo "=========================================="
echo "PORT: $PORT"
echo "WEBSITES_PORT: $WEBSITES_PORT"
echo ""

echo "=========================================="
echo "🔍 Environment Variable Check"
echo "=========================================="
echo "LLM_PROVIDER: ${LLM_PROVIDER:-NOT SET}"
echo "LLM_MODEL_NAME: ${LLM_MODEL_NAME:-NOT SET}"
echo "GROQ_API_KEY: ${GROQ_API_KEY:0:5}... (truncated)"
echo "REDIS_HOST: ${REDIS_HOST:-NOT SET}"
echo ""

echo "=========================================="
echo "📦 Verifying Dependencies"
echo "=========================================="
# Safe import checks
python3 -c "import fastapi; print('✅ FastAPI:', fastapi.__version__)"
python3 -c "import uvicorn; print('✅ Uvicorn:', uvicorn.__version__)"
python3 -c "import pydantic_settings; print('✅ Pydantic-Settings installed')"
python3 -c "import dateutil; print('✅ Python-Dateutil installed')"
python3 -c "import tiktoken; print('✅ Tiktoken installed')"
echo ""

echo "=========================================="
echo "🧪 Testing Application Import"
echo "=========================================="
# This helps identify exactly which file/import is failing
python3 << 'EOF'
import sys
import traceback
import os

print("Testing app import sequence...")
try:
    print("1/4: helpers.utils...")
    from helpers.utils import get_logger
    print("✅ helpers.utils")

    print("2/4: app.config...")
    from app.config import settings
    print(f"✅ app.config")

    print("3/4: agents.models...")
    # Temporarily bypass API key requirement for import test if needed
    os.environ.setdefault('GROQ_API_KEY', 'test_key')
    from agents.models import LLM_MODEL
    print(f"✅ agents.models")

    print("4/4: main app...")
    from main import app
    print(f"✅ main.app initialized: {app.title}")

    print("\n✅ ALL IMPORTS SUCCESSFUL")
    sys.exit(0)
except Exception as e:
    print(f"\n❌ IMPORT FAILED")
    print(f"Error Type: {type(e).__name__}")
    print(f"Error Message: {str(e)}")
    print("\nFull Traceback:")
    traceback.print_exc()
    sys.exit(1)
EOF

echo ""
echo "=========================================="
echo "🚦 Starting Gunicorn Server"
echo "=========================================="
# Using worker-class uvicorn.workers.UvicornWorker
# Removed --preload to avoid issues with some libraries during master process initialization
exec gunicorn main:app \
    --workers 4 \
    --worker-class uvicorn.workers.UvicornWorker \
    --bind 0.0.0.0:$PORT \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    --log-level info \
    --capture-output \
    --enable-stdio-inheritance
