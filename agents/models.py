import os
from pydantic_ai.models.openai import OpenAIModel
from pydantic_ai.models.gemini import GeminiModel
from dotenv import load_dotenv
from helpers.utils import get_logger

load_dotenv()
logger = get_logger(__name__)

# Get configurations from environment variables with safe defaults
LLM_PROVIDER = os.getenv('LLM_PROVIDER', 'groq').lower()
LLM_MODEL_NAME = os.getenv('LLM_MODEL_NAME', 'llama-3.3-70b-versatile')

# Debug logging
logger.info(f"LLM_PROVIDER loaded: '{LLM_PROVIDER}'")
logger.info(f"LLM_MODEL_NAME loaded: '{LLM_MODEL_NAME}'")

# Configure the model based on provider using standard pydantic-ai model classes
try:
    if LLM_PROVIDER == 'gemini':
        gemini_key = os.getenv('GEMINI_API_KEY')
        if not gemini_key:
            raise ValueError("GEMINI_API_KEY environment variable is required for gemini provider")
        LLM_MODEL = GeminiModel(
            LLM_MODEL_NAME,
            api_key=gemini_key,
        )
    elif LLM_PROVIDER == 'vllm' or LLM_PROVIDER == 'openai' or LLM_PROVIDER == 'groq':
        # All of these are OpenAI-compatible
        api_key = None
        base_url = None
        
        if LLM_PROVIDER == 'groq':
            api_key = os.getenv('GROQ_API_KEY')
            base_url = 'https://api.groq.com/openai/v1'
            if not api_key:
                raise ValueError("GROQ_API_KEY environment variable is required for groq provider")
        elif LLM_PROVIDER == 'openai':
            api_key = os.getenv('OPENAI_API_KEY')
            if not api_key:
                raise ValueError("OPENAI_API_KEY environment variable is required for openai provider")
        elif LLM_PROVIDER == 'vllm':
            api_key = os.getenv('INFERENCE_API_KEY', 'dummy')
            base_url = os.getenv('INFERENCE_ENDPOINT_URL')
            if not base_url:
                raise ValueError("INFERENCE_ENDPOINT_URL environment variable is required for vllm provider")

        LLM_MODEL = OpenAIModel(
            model_name=LLM_MODEL_NAME,
            base_url=base_url,
            api_key=api_key,
        )
    else:
        # Fallback to a default if unknown - helpful during testing
        logger.warning(f"Unknown LLM_PROVIDER: {LLM_PROVIDER}. Falling back to default initialization.")
        LLM_MODEL = OpenAIModel('gpt-4o') # Just a placeholder
    
    logger.info(f"✅ LLM Model initialized successfully: {LLM_PROVIDER}/{LLM_MODEL_NAME}")
    
except Exception as e:
    logger.error(f"❌ Failed to initialize LLM Model: {str(e)}")
    # If we are in startup test mode (e.g. during Docker build or start.sh test), 
    # we might want to not crash, but for production it's better to fail early.
    raise