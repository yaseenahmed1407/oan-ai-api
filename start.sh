#!/bin/bash
set -e

echo "=========================================="
echo "Starting OAN AI API Container"
echo "=========================================="
echo "Python version: $(python --version)"
echo "Working directory: $(pwd)"
echo "Files in directory:"
ls -la
echo ""

echo "=========================================="
echo "Environment Variables Check"
echo "=========================================="
echo "LLM_PROVIDER: ${LLM_PROVIDER:-NOT SET}"
echo "LLM_MODEL_NAME: ${LLM_MODEL_NAME:-NOT SET}"
echo "GROQ_API_KEY: ${GROQ_API_KEY:0:20}... (truncated)"
echo "PORT: ${PORT:-NOT SET}"
echo "WEBSITES_PORT: ${WEBSITES_PORT:-NOT SET}"
echo ""

echo "=========================================="
echo "Testing Python Imports"
echo "=========================================="

# Test critical imports
python3 << 'EOF'
import sys
import traceback

def test_import(module_name, description):
    try:
        __import__(module_name)
        print(f"✅ {description}")
        return True
    except Exception as e:
        print(f"❌ {description}")
        print(f"   Error: {str(e)}")
        traceback.print_exc()
        return False

print("Testing imports...")
success = True
success &= test_import("fastapi", "FastAPI")
success &= test_import("uvicorn", "Uvicorn")
success &= test_import("gunicorn", "Gunicorn")
success &= test_import("helpers.utils", "Helpers Utils")
success &= test_import("app.config", "App Config")
success &= test_import("app.core.cache", "App Cache")
success &= test_import("agents.models", "Agents Models")

if not success:
    print("\n❌ Import test failed!")
    sys.exit(1)

print("\n✅ All imports successful!")

# Try to import the main app
try:
    from main import app
    print("✅ Main app imported successfully")
    print(f"   App title: {app.title}")
except Exception as e:
    print(f"❌ Failed to import main app: {str(e)}")
    traceback.print_exc()
    sys.exit(1)
EOF

if [ $? -ne 0 ]; then
    echo ""
    echo "=========================================="
    echo "❌ Import test failed - exiting"
    echo "=========================================="
    exit 1
fi

echo ""
echo "=========================================="
echo "Starting Gunicorn"
echo "=========================================="

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
