"""
Azure Functions entry point for FastAPI application
"""
import azure.functions as func
from main import app as fastapi_app
import logging

# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger("azure.functions")

# Create Azure Functions app
app = func.AsgiFunctionApp(app=fastapi_app, http_auth_level=func.AuthLevel.ANONYMOUS)

logger.info("Azure Functions FastAPI app initialized successfully")
