"""Job search integration with JSearch."""

from typing import Any

import httpx
from sqlalchemy.orm import Session

from app.config import get_settings
from app.core.cache import get_cached_job_search, set_cached_job_search
from app.exceptions import ExternalServiceError, ValidationError
from app.models.user import User
from app.repositories.search_history_repository import SearchHistoryRepository
from app.schemas.job import JobPosting, JobSearchRequest, JobSearchResponse

settings = get_settings()


class JobSearchService:
    """Fetches live postings from JSearch and normalizes the response shape."""

    def __init__(self, db: Session) -> None:
        self.db = db
        self.search_history_repo = SearchHistoryRepository(db)

    async def search_jobs(
        self,
        payload: JobSearchRequest,
        user: User | None = None,
        record_history: bool = True,
    ) -> JobSearchResponse:
        cache_payload = payload.model_dump()
        cached = get_cached_job_search(cache_payload)
        if cached is not None:
            return JobSearchResponse(**cached, cached=True)

        merged_jobs: dict[str, JobPosting] = {}
        async with httpx.AsyncClient(timeout=30.0) as client:
            for city in payload.cities:
                city_jobs = await self._fetch_city_jobs(client, payload, city)
                for job in city_jobs:
                    merged_jobs[job.job_id] = job

        jobs = list(merged_jobs.values())
        response = JobSearchResponse(total=len(jobs), jobs=jobs, cached=False)
        set_cached_job_search(cache_payload, response.model_dump(exclude={"cached"}))

        if user is not None and record_history:
            self.search_history_repo.create(
                user_id=user.id,
                niche=payload.niche,
                country=payload.country,
                cities=payload.cities,
            )

        return response

    async def get_job_description_by_id(self, job_id: str) -> str:
        """Fetch full job description from JSearch job-details endpoint."""
        url = f"{settings.jsearch_base_url}/job-details"
        headers = {
            "X-RapidAPI-Key": settings.rapidapi_key,
            "X-RapidAPI-Host": settings.jsearch_host,
        }
        params = {"job_id": job_id, "country": "us"}

        async with httpx.AsyncClient(timeout=30.0) as client:
            try:
                response = await client.get(url, headers=headers, params=params)
                response.raise_for_status()
            except httpx.HTTPError as exc:
                raise ExternalServiceError("Failed to fetch job details from JSearch.") from exc

        data = response.json().get("data", [])
        if not data:
            raise ValidationError("Job not found for the provided job_id.")

        description = data[0].get("job_description") or ""
        if not description.strip():
            raise ValidationError("Job description is empty for the provided job_id.")
        return description

    async def _fetch_city_jobs(
        self,
        client: httpx.AsyncClient,
        payload: JobSearchRequest,
        city: str,
    ) -> list[JobPosting]:
        query = f"{payload.niche} jobs in {city}"
        url = f"{settings.jsearch_base_url}/search-v2"
        headers = {
            "X-RapidAPI-Key": settings.rapidapi_key,
            "X-RapidAPI-Host": settings.jsearch_host,
        }
        params = {
            "query": query,
            "num_pages": "1",
            "country": payload.country,
            "date_posted": "all",
        }

        try:
            response = await client.get(url, headers=headers, params=params)
            response.raise_for_status()
        except httpx.HTTPError as exc:
            raise ExternalServiceError(
                f"JSearch request failed for city '{city}'."
            ) from exc

        raw_jobs = response.json().get("data", {}).get("jobs", [])
        return [self._normalize_job(item) for item in raw_jobs if item.get("job_id")]

    def _normalize_job(self, item: dict[str, Any]) -> JobPosting:
        """Map JSearch fields to the stable JSON contract used by all frontends."""
        location_parts = [
            item.get("job_city"),
            item.get("job_state"),
            item.get("job_country"),
        ]
        location = ", ".join(part for part in location_parts if part)

        return JobPosting(
            job_id=str(item.get("job_id")),
            title=item.get("job_title") or "Unknown title",
            company_name=item.get("employer_name") or "Unknown company",
            location=location or "Unknown location",
            description=item.get("job_description") or "",
            apply_link=item.get("job_apply_link") or "",
            source_platform=item.get("job_publisher") or "unknown",
            posted_date=item.get("job_posted_at_datetime_utc")
            or item.get("job_posted_at")
            or None,
        )
