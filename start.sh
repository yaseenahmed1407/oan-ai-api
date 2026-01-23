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
echo "REDIS_HOST: ${REDIS_HOST:-NOT SET}"
echo "USE_REDIS: ${USE_REDIS:-NOT SET}"
echo ""

echo "=========================================="
echo "📦 Verifying Dependencies"
echo "=========================================="
python3 -c "import fastapi; print('✅ FastAPI')"
python3 -c "import uvicorn; print('✅ Uvicorn')"
python3 -c "import pydantic_settings; print('✅ Pydantic-Settings')"
echo ""

echo "=========================================="
echo "🧪 Testing Application Import"
echo "=========================================="
python3 << 'EOF'
import sys
import traceback
import os

try:
    print("Testing main app import...")
    from main import app
    print(f"✅ main.app initialized: {app.title}")
    sys.exit(0)
except Exception as e:
    print(f"\n❌ IMPORT FAILED: {str(e)}")
    traceback.print_exc()
    sys.exit(1)
EOF

echo ""
echo "=========================================="
echo "🚦 Starting Gunicorn Server (Debug Mode)"
echo "=========================================="
# Using 1 worker for better log clarity during debugging
# Set timeout to 120s as LLM calls can be slow
exec gunicorn main:app \
    --workers 1 \
    --worker-class uvicorn.workers.UvicornWorker \
    --bind 0.0.0.0:$PORT \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    --log-level debug \
    --capture-output \
    --enable-stdio-inheritance
