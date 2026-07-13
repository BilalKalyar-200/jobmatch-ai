"""In-memory TTL cache for short-lived job search responses."""

import hashlib
import json
from typing import Any, Optional

from cachetools import TTLCache

from app.config import get_settings

settings = get_settings()

# A process-local cache is enough for a single-instance deployment.
# For multi-instance production, replace with Redis while keeping the same interface.
_job_search_cache: TTLCache[str, Any] = TTLCache(
    maxsize=512,
    ttl=settings.job_search_cache_ttl_seconds,
)


def _make_cache_key(prefix: str, payload: dict[str, Any]) -> str:
    """Build a stable cache key from request parameters."""
    serialized = json.dumps(payload, sort_keys=True, default=str)
    digest = hashlib.sha256(serialized.encode("utf-8")).hexdigest()
    return f"{prefix}:{digest}"


def get_cached_job_search(payload: dict[str, Any]) -> Optional[Any]:
    """Return cached job search results when present."""
    key = _make_cache_key("job_search", payload)
    return _job_search_cache.get(key)


def set_cached_job_search(payload: dict[str, Any], value: Any) -> None:
    """Store job search results for the configured TTL."""
    key = _make_cache_key("job_search", payload)
    _job_search_cache[key] = value
