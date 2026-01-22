"""
Test script to simulate application startup and identify import errors
"""
import sys
import os

# Set minimal required environment variables for testing
os.environ['LLM_PROVIDER'] = 'groq'
os.environ['LLM_MODEL_NAME'] = 'llama-3.3-70b-versatile'
os.environ['GROQ_API_KEY'] = 'test_key'
os.environ['USE_REDIS'] = 'false'

print("=" * 60)
print("Testing Application Startup Sequence")
print("=" * 60)

try:
    print("\n1. Testing helpers.utils import...")
    from helpers.utils import get_logger
    logger = get_logger(__name__)
    print("   ✅ helpers.utils imported successfully")
except Exception as e:
    print(f"   ❌ Failed to import helpers.utils: {e}")
    sys.exit(1)

try:
    print("\n2. Testing app.config import...")
    from app.config import settings
    print(f"   ✅ app.config imported successfully")
    print(f"   - LLM Provider: {settings.llm_provider}")
    print(f"   - LLM Model: {settings.llm_model_name}")
except Exception as e:
    print(f"   ❌ Failed to import app.config: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

try:
    print("\n3. Testing app.core.cache import...")
    from app.core.cache import cache
    print("   ✅ app.core.cache imported successfully")
except Exception as e:
    print(f"   ❌ Failed to import app.core.cache: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

try:
    print("\n4. Testing agents.models import...")
    from agents.models import LLM_MODEL
    print("   ✅ agents.models imported successfully")
    print(f"   - Model type: {type(LLM_MODEL)}")
except Exception as e:
    print(f"   ❌ Failed to import agents.models: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

try:
    print("\n5. Testing routers import...")
    from app.routers import chat_router, suggestions_router, transcribe_router, tts_router
    from app.routers.health import router as health_router
    print("   ✅ All routers imported successfully")
except Exception as e:
    print(f"   ❌ Failed to import routers: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

try:
    print("\n6. Testing FastAPI app creation...")
    from main import create_app
    app = create_app()
    print("   ✅ FastAPI app created successfully")
    print(f"   - App title: {app.title}")
except Exception as e:
    print(f"   ❌ Failed to create FastAPI app: {e}")
    import traceback
    traceback.print_exc()
    sys.exit(1)

print("\n" + "=" * 60)
print("✅ ALL TESTS PASSED - Application should start successfully")
print("=" * 60)
