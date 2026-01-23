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

def get_model():
    """ Returns the LLM model instance based on environment variables. 
    This is deferred to avoid startup crashes if API keys are missing.
    """
    try:
        if LLM_PROVIDER == 'gemini':
            gemini_key = os.getenv('GEMINI_API_KEY')
            if not gemini_key:
                logger.error("GEMINI_API_KEY is missing")
                return OpenAIModel('gpt-4o') # Fallback or handle later
            return GeminiModel(
                LLM_MODEL_NAME,
                api_key=gemini_key,
            )
        elif LLM_PROVIDER in ['vllm', 'openai', 'groq']:
            api_key = None
            base_url = None
            
            if LLM_PROVIDER == 'groq':
                api_key = os.getenv('GROQ_API_KEY')
                base_url = 'https://api.groq.com/openai/v1'
            elif LLM_PROVIDER == 'openai':
                api_key = os.getenv('OPENAI_API_KEY')
            elif LLM_PROVIDER == 'vllm':
                api_key = os.getenv('INFERENCE_API_KEY', 'dummy')
                base_url = os.getenv('INFERENCE_ENDPOINT_URL')

            return OpenAIModel(
                model_name=LLM_MODEL_NAME,
                base_url=base_url,
                api_key=api_key,
            )
        else:
            logger.warning(f"Unknown LLM_PROVIDER: {LLM_PROVIDER}")
            return OpenAIModel('gpt-4o')
    except Exception as e:
        logger.error(f"Error initializing model: {e}")
        return OpenAIModel('gpt-4o')

# Global instance
LLM_MODEL = get_model()