"""Job search and match schemas."""

from datetime import datetime
from typing import List, Optional

from pydantic import BaseModel, Field, field_validator


class JobSearchRequest(BaseModel):
    """Parameters for searching live job postings."""

    niche: str = Field(min_length=1, max_length=255, description="Role or niche, e.g. data scientist")
    country: str = Field(
        min_length=2,
        max_length=2,
        description="ISO 3166-1 alpha-2 country code, e.g. us, gb, de",
    )
    cities: List[str] = Field(min_length=1, max_length=20)

    @field_validator("country")
    @classmethod
    def normalize_country(cls, value: str) -> str:
        return value.lower()

    @field_validator("cities")
    @classmethod
    def normalize_cities(cls, value: List[str]) -> List[str]:
        cleaned = [city.strip() for city in value if city and city.strip()]
        if not cleaned:
            raise ValueError("At least one non-empty city is required.")
        return cleaned


class JobPosting(BaseModel):
    """Normalized job posting returned to any frontend client."""

    job_id: str
    title: str
    company_name: str
    location: str
    description: str
    apply_link: str
    source_platform: str
    posted_date: Optional[str] = None


class JobSearchResponse(BaseModel):
    """Merged and deduplicated search results."""

    total: int
    jobs: List[JobPosting]
    cached: bool = False


class JobMatchRequest(BaseModel):
    """Score a stored resume against a job by id or raw description."""

    job_id: Optional[str] = Field(default=None, min_length=1)
    job_description: Optional[str] = Field(default=None, min_length=20, max_length=20000)

    @field_validator("job_description")
    @classmethod
    def validate_job_reference(cls, value: Optional[str], info) -> Optional[str]:
        # Cross-field validation is completed in the service layer as well.
        return value


class JobMatchResponse(BaseModel):
    """Resume to job match output."""

    final_score: float = Field(ge=0, le=100)
    keyword_score: float = Field(ge=0, le=100)
    semantic_score: float = Field(ge=0, le=100)
    matched_keywords: List[str]
    missing_keywords: List[str]
    scoring_formula: str
