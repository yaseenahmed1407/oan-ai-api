from fastapi import APIRouter, HTTPException, status
from app.utils import cache
from app.config import settings
import time
from typing import Dict, Any

router = APIRouter(prefix="/health", tags=["health"])

# Track when the application started
START_TIME = time.time()

@router.get("", status_code=status.HTTP_200_OK)
async def health_root():
    """Root health check endpoint for Azure Functions startup probe"""
    return {"status": "ok", "message": "Service is running"}

async def check_cache_connection() -> Dict[str, Any]:
    """Check Redis cache connection"""
    try:
        test_key = "health_check_test"
        test_value = "test"
        await cache.set(test_key, test_value, ttl=5)
        cached_value = await cache.get(test_key)
        return {
            "status": "healthy" if cached_value == test_value else "unhealthy",
            "latency_ms": 0  # TODO: Add actual latency measurement
        }
    except Exception as e:
        return {
            "status": "unhealthy",
            "error": str(e)
        }

@router.get("/live", status_code=status.HTTP_200_OK)
async def liveness():
    """
    Liveness probe - simple check to see if the application is running
    Used by Kubernetes to know when to restart the pod
    """
    return {"status": "alive"}

@router.get("/ready", status_code=status.HTTP_200_OK)
async def readiness():
    """
    Readiness probe - checks if the application is ready to handle traffic
    Used by Kubernetes to know when to send traffic to the pod
    """
    cache_health = await check_cache_connection()
    
    return {"status": "ready", "cache": cache_health}

@router.get("/", status_code=status.HTTP_200_OK)
async def health_check():
    """
    Health check that includes:
    - Application metadata (version, uptime)
    - Service dependencies (Redis cache)
    """
    cache_health = await check_cache_connection()
    uptime_seconds = int(time.time() - START_TIME)
    
    health_status = {
        "app": {
            "name": settings.app_name,
            "environment": settings.environment,
            "uptime_seconds": uptime_seconds
        },
        "dependencies": {
            "cache": cache_health
        }
    }
    
    return health_status
    
    return health_status 