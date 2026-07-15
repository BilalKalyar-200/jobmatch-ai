"""Rate limiting configuration shared across the application."""

from slowapi import Limiter
from slowapi.util import get_remote_address

# A single shared limiter instance. The default limit applies to every
# route unless a specific endpoint overrides it with its own decorator.
limiter = Limiter(key_func=get_remote_address, default_limits=["60/minute"])