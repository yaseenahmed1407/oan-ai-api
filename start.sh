#!/bin/bash

echo "=========================================="
echo "Starting OAN AI API Container"
echo "=========================================="
echo "Python version: $(python --version)"
echo "Working directory: $(pwd)"
echo ""

echo "=========================================="
echo "Environment Variables Check"
echo "=========================================="
echo "LLM_PROVIDER: ${LLM_PROVIDER:-NOT SET}"
echo "LLM_MODEL_NAME: ${LLM_MODEL_NAME:-NOT SET}"
echo "GROQ_API_KEY: ${GROQ_API_KEY:0:20}..."
echo "PORT: ${PORT:-80}"
echo "WEBSITES_PORT: ${WEBSITES_PORT:-NOT SET}"
echo ""

# Set minimal required env vars if not set
export LLM_PROVIDER=${LLM_PROVIDER:-groq}
export LLM_MODEL_NAME=${LLM_MODEL_NAME:-llama-3.3-70b-versatile}
export GROQ_API_KEY=${GROQ_API_KEY:-dummy_key}
export ENVIRONMENT=${ENVIRONMENT:-production}

echo "=========================================="
echo "Testing Critical Python Imports"
echo "=========================================="

# Test imports with better error handling
python3 << 'EOF'
import sys
import traceback

def test_import(module_name, description):
    try:
        __import__(module_name)
        print(f"✅ {description}")
        return True
    except Exception as e:
        print(f"❌ {description}: {str(e)}")
        return False

print("Testing imports...")
success = True
success &= test_import("fastapi", "FastAPI")
success &= test_import("uvicorn", "Uvicorn")
success &= test_import("gunicorn", "Gunicorn")

# Test app imports (non-critical, just warn)
if not test_import("helpers.utils", "Helpers Utils"):
    print("⚠️  Warning: helpers.utils import failed (non-critical)")
    
if not test_import("app.config", "App Config"):
    print("⚠️  Warning: app.config import failed (non-critical)")

if not test_import("app.core.cache", "App Cache"):
    print("⚠️  Warning: app.core.cache import failed (non-critical)")

# Try to import the main app
try:
    from main import app
    print("✅ Main app imported successfully")
    print(f"   App title: {app.title}")
except Exception as e:
    print(f"❌ Failed to import main app: {str(e)}")
    print("\nFull traceback:")
    traceback.print_exc()
    print("\n⚠️  Attempting to start anyway...")
    sys.exit(1)

print("\n✅ All critical imports successful!")
EOF

if [ $? -ne 0 ]; then
    echo ""
    echo "=========================================="
    echo "❌ Critical import test failed - exiting"
    echo "=========================================="
    echo "This usually means:"
    echo "1. Missing environment variables in Azure"
    echo "2. Missing Python dependencies"
    echo "3. Code syntax errors"
    exit 1
fi

echo ""
echo "=========================================="
echo "Starting Gunicorn with Uvicorn Workers"
echo "=========================================="
echo "Binding to: 0.0.0.0:${PORT:-80}"
echo "Workers: 2"
echo ""

# Start gunicorn with the application
exec gunicorn main:app \
    -w 2 \
    -k uvicorn.workers.UvicornWorker \
    --bind 0.0.0.0:${PORT:-80} \
    --timeout 120 \
    --access-logfile - \
    --error-logfile - \
    --log-level info \
    --capture-output \
    --enable-stdio-inheritance
