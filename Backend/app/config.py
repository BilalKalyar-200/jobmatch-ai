"""Application configuration loaded from environment variables."""

from functools import lru_cache
from typing import List

from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    """Central settings object. Values are read from the environment or a .env file."""

    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    # Application
    app_name: str = "JobMatch API"
    app_version: str = "1.0.0"
    debug: bool = False
    api_v1_prefix: str = "/api/v1"

    # Server bind host is chosen by the process manager (uvicorn, Render, Railway).
    # Do not hardcode localhost in application logic.
    allowed_origins: str = Field(
        default="http://localhost:3000,http://localhost:5173,http://127.0.0.1:3000",
        description="Comma-separated list of CORS allowed origins.",
    )

    # Database
    database_url: str = Field(
        ...,
        description="PostgreSQL connection URL, e.g. postgresql+psycopg2://user:pass@host:5432/db",
    )

    # JWT
    jwt_secret_key: str = Field(..., min_length=32)
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 30
    refresh_token_expire_days: int = 7

    # RapidAPI / JSearch
    rapidapi_key: str = Field(..., description="RapidAPI key for JSearch.")
    jsearch_base_url: str = "https://jsearch.p.rapidapi.com"
    jsearch_host: str = "jsearch.p.rapidapi.com"
    job_search_cache_ttl_seconds: int = 300

    # Resume upload
    max_resume_size_mb: int = 5

    # Match scoring weights (documented in matching/scorer.py)
    keyword_score_weight: float = 0.4
    semantic_score_weight: float = 0.6

    @property
    def cors_origins(self) -> List[str]:
        """Parse comma-separated origins into a list for FastAPI CORSMiddleware."""
        return [origin.strip() for origin in self.allowed_origins.split(",") if origin.strip()]

    @property
    def max_resume_size_bytes(self) -> int:
        return self.max_resume_size_mb * 1024 * 1024


@lru_cache
def get_settings() -> Settings:
    """Return a cached Settings instance so config is parsed once per process."""
    return Settings()
