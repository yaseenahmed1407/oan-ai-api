"""
Core cache instance configuration using Redis and aiocache.

This module provides the cache instance that other parts of the application can use.
Falls back to in-memory cache if Redis is not available (e.g., in cloud deployments).
"""
import os
from aiocache import Cache
from aiocache.serializers import JsonSerializer
from app.config import settings
from helpers.utils import get_logger

logger = get_logger(__name__)

# Check if we should use Redis or fall back to in-memory cache
USE_REDIS = os.getenv("USE_REDIS", "true").lower() == "true"

if USE_REDIS:
    # Configure Redis cache
    cache = Cache(
        Cache.REDIS,
        endpoint=settings.redis_host,
        port=settings.redis_port,
        db=settings.redis_db,
        serializer=JsonSerializer(),
        ttl=settings.default_cache_ttl,
        # Enhanced connection settings
        timeout=settings.redis_socket_timeout,
        pool_max_size=settings.redis_max_connections,
        # Add key prefix support
        key_builder=lambda key, namespace: f"{settings.redis_key_prefix}{namespace}:{key}" if namespace else f"{settings.redis_key_prefix}{key}",
    )
    logger.info(
        f"Cache configured with Redis at {settings.redis_host}:{settings.redis_port} "
        f"(DB: {settings.redis_db}, Prefix: {settings.redis_key_prefix}, "
        f"Max Connections: {settings.redis_max_connections})"
    )
else:
    # Use in-memory cache as fallback
    cache = Cache(
        Cache.MEMORY,
        serializer=JsonSerializer(),
        ttl=settings.default_cache_ttl,
    )
    logger.warning(
        "⚠️ Using in-memory cache (Redis disabled). "
        "Cache will not persist across restarts or scale across instances."
    ) 