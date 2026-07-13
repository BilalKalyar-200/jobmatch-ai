"""Job search and match routes."""

from fastapi import APIRouter

from app.dependencies import CurrentUser, DbSession
from app.schemas.job import JobMatchRequest, JobMatchResponse, JobSearchRequest, JobSearchResponse
from app.services.job_search_service import JobSearchService
from app.services.match_service import MatchService

router = APIRouter(prefix="/jobs", tags=["Jobs"])


@router.post("/search", response_model=JobSearchResponse)
async def search_jobs(
    payload: JobSearchRequest,
    current_user: CurrentUser,
    db: DbSession,
) -> JobSearchResponse:
    """
    Search live postings via JSearch.

    Queries once per city, merges results, and deduplicates by job_id.
    """
    return await JobSearchService(db).search_jobs(payload, user=current_user)


@router.post("/match", response_model=JobMatchResponse)
async def match_resume_to_job(
    payload: JobMatchRequest,
    current_user: CurrentUser,
    db: DbSession,
) -> JobMatchResponse:
    """Score the user's stored resume against a job description or job_id."""
    return await MatchService(db).score_match(current_user, payload)
