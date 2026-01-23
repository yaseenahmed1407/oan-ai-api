import os
from pydantic_ai.models.openai import OpenAIModel
from pydantic_ai.models.gemini import GeminiModel
from pydantic_ai.models.test import TestModel
from dotenv import load_dotenv
from helpers.utils import get_logger

load_dotenv()
logger = get_logger(__name__)

# Get configurations from environment variables
LLM_PROVIDER = os.getenv('LLM_PROVIDER', 'gemini').lower()
LLM_MODEL_NAME = os.getenv('LLM_MODEL_NAME', 'gemini-2.0-flash')

def get_model():
    """ 
    Initializes the model lazily. 
    If keys are missing, returns a TestModel to prevent startup crashes.
    """
    try:
        if LLM_PROVIDER == 'gemini':
            api_key = os.getenv('GEMINI_API_KEY')
            if api_key:
                return GeminiModel(LLM_MODEL_NAME, api_key=api_key)
            logger.error("❌ GEMINI_API_KEY is missing!")
            
        elif LLM_PROVIDER == 'groq':
            api_key = os.getenv('GROQ_API_KEY')
            if api_key:
                return OpenAIModel(
                    model_name=LLM_MODEL_NAME,
                    base_url='https://api.groq.com/openai/v1',
                    api_key=api_key
                )
            logger.error("❌ GROQ_API_KEY is missing!")
            
        elif LLM_PROVIDER == 'openai':
            api_key = os.getenv('OPENAI_API_KEY')
            if api_key:
                return OpenAIModel(model_name=LLM_MODEL_NAME, api_key=api_key)
            logger.error("❌ OPENAI_API_KEY is missing!")

        # Fallback to TestModel if provider is unknown or keys are missing
        # This prevents the constructor crash you saw in the logs
        logger.warning(f"⚠️ Falling back to TestModel for provider '{LLM_PROVIDER}'")
        return TestModel()
        
    except Exception as e:
        logger.error(f"💥 Critical error in get_model: {e}")
        return TestModel()

# Global instance - initialized safely
LLM_MODEL = get_model()