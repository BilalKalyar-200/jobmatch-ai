"""Saved jobs and search history schemas."""

from datetime import datetime
from typing import List
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field

from app.schemas.job import JobPosting


class SaveJobRequest(BaseModel):
    """Bookmark a job for the current user."""

    job_id: str = Field(min_length=1)
    title: str = Field(min_length=1)
    company_name: str = Field(min_length=1)
    location: str = ""
    description: str = ""
    apply_link: str = ""
    source_platform: str = ""
    posted_date: str | None = None


class SavedJobResponse(BaseModel):
    """Saved job record with embedded job payload."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    external_job_id: str
    job: JobPosting
    created_at: datetime


class SavedJobsListResponse(BaseModel):
    """List of bookmarked jobs."""

    total: int
    saved_jobs: List[SavedJobResponse]


class SearchHistoryItem(BaseModel):
    """One past search entry."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    niche: str
    country: str
    cities: List[str]
    created_at: datetime


class SearchHistoryListResponse(BaseModel):
    """List of prior searches."""

    total: int
    searches: List[SearchHistoryItem]
