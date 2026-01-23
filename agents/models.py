import os
from pydantic_ai.models.openai import OpenAIModel
from pydantic_ai.models.gemini import GeminiModel
from pydantic_ai.providers.openai import OpenAIProvider
from pydantic_ai.providers.google_gla import GoogleGLAProvider
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

# Configure the model based on provider
try:
    if LLM_PROVIDER == 'gemini':
        gemini_key = os.getenv('GEMINI_API_KEY')
        if not gemini_key:
            raise ValueError("GEMINI_API_KEY environment variable is required for gemini provider")
        LLM_MODEL = GeminiModel(
            LLM_MODEL_NAME,
            provider=GoogleGLAProvider(
                api_key=gemini_key,
            )
        )
    elif LLM_PROVIDER == 'vllm':
        endpoint_url = os.getenv('INFERENCE_ENDPOINT_URL')
        api_key = os.getenv('INFERENCE_API_KEY', 'dummy')
        if not endpoint_url:
            raise ValueError("INFERENCE_ENDPOINT_URL environment variable is required for vllm provider")
        LLM_MODEL = OpenAIModel(
            LLM_MODEL_NAME,
            provider=OpenAIProvider(
                base_url=endpoint_url, 
                api_key=api_key,  
            ),
        )
    elif LLM_PROVIDER == 'openai':
        openai_key = os.getenv('OPENAI_API_KEY')
        if not openai_key:
            raise ValueError("OPENAI_API_KEY environment variable is required for openai provider")
        LLM_MODEL = OpenAIModel(
            LLM_MODEL_NAME,
            provider=OpenAIProvider(
                api_key=openai_key,
            ),
        )
    elif LLM_PROVIDER == 'groq':
        groq_key = os.getenv('GROQ_API_KEY')
        if not groq_key:
            raise ValueError("GROQ_API_KEY environment variable is required for groq provider")
        LLM_MODEL = OpenAIModel(
            LLM_MODEL_NAME,
            provider=OpenAIProvider(
                base_url='https://api.groq.com/openai/v1',
                api_key=groq_key,
            ),
        )
    else:
        raise ValueError(f"Invalid LLM_PROVIDER: {LLM_PROVIDER}. Must be one of: 'gemini', 'openai', 'vllm', 'groq'")
    
    logger.info(f"✅ LLM Model initialized successfully: {LLM_PROVIDER}/{LLM_MODEL_NAME}")
    
except Exception as e:
    logger.error(f"❌ Failed to initialize LLM Model: {str(e)}")
    logger.error(f"   Provider: {LLM_PROVIDER}")
    logger.error(f"   Model: {LLM_MODEL_NAME}")
    logger.error(f"   Make sure the required API key environment variable is set!")
    raise