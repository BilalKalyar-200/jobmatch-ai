"""Saved jobs and search history routes."""

from uuid import UUID

from fastapi import APIRouter, status

from app.dependencies import CurrentUser, DbSession
from app.schemas.auth import MessageResponse
from app.schemas.saved_job import (
    SaveJobRequest,
    SavedJobResponse,
    SavedJobsListResponse,
    SearchHistoryListResponse,
)
from app.services.saved_job_service import SavedJobService

router = APIRouter(prefix="/saved", tags=["Saved Jobs"])


@router.post("/jobs", response_model=SavedJobResponse, status_code=status.HTTP_201_CREATED)
def save_job(
    payload: SaveJobRequest,
    current_user: CurrentUser,
    db: DbSession,
) -> SavedJobResponse:
    """Bookmark a job for the authenticated user."""
    return SavedJobService(db).save_job(current_user, payload)


@router.delete("/jobs/{job_id}", response_model=MessageResponse)
def unsave_job(job_id: str, current_user: CurrentUser, db: DbSession) -> MessageResponse:
    """Remove a bookmarked job."""
    SavedJobService(db).unsave_job(current_user, job_id)
    return MessageResponse(message="Job removed from saved list.")


@router.get("/jobs", response_model=SavedJobsListResponse)
def list_saved_jobs(current_user: CurrentUser, db: DbSession) -> SavedJobsListResponse:
    """List all jobs saved by the user."""
    return SavedJobService(db).list_saved_jobs(current_user)


@router.get("/searches", response_model=SearchHistoryListResponse)
def list_search_history(
    current_user: CurrentUser,
    db: DbSession,
) -> SearchHistoryListResponse:
    """List the user's past job searches."""
    return SavedJobService(db).list_search_history(current_user)


@router.delete("/searches/{search_id}", status_code=status.HTTP_204_NO_CONTENT)
def delete_search_history(
    search_id: UUID,
    current_user: CurrentUser,
    db: DbSession,
) -> None:
    """Delete a single search history entry for the authenticated user."""
    SavedJobService(db).delete_search_history(current_user, search_id)
