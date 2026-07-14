"""Saved jobs and search history business logic."""

from uuid import UUID

from sqlalchemy.orm import Session

from app.exceptions import NotFoundError
from app.models.user import User
from app.repositories.saved_job_repository import SavedJobRepository
from app.repositories.search_history_repository import SearchHistoryRepository
from app.schemas.job import JobPosting
from app.schemas.saved_job import (
    SaveJobRequest,
    SavedJobResponse,
    SavedJobsListResponse,
    SearchHistoryItem,
    SearchHistoryListResponse,
)


class SavedJobService:
    """Bookmark management and search history listing."""

    def __init__(self, db: Session) -> None:
        self.saved_job_repo = SavedJobRepository(db)
        self.search_history_repo = SearchHistoryRepository(db)

    def save_job(self, user: User, payload: SaveJobRequest) -> SavedJobResponse:
        existing = self.saved_job_repo.get_by_user_and_job_id(user.id, payload.job_id)
        if existing:
            return self._to_saved_job_response(existing)

        job_data = payload.model_dump()
        saved = self.saved_job_repo.create(
            user_id=user.id,
            external_job_id=payload.job_id,
            job_data=job_data,
        )
        return self._to_saved_job_response(saved)

    def unsave_job(self, user: User, job_id: str) -> None:
        existing = self.saved_job_repo.get_by_user_and_job_id(user.id, job_id)
        if existing is None:
            raise NotFoundError("Saved job not found.")
        self.saved_job_repo.delete(existing)

    def list_saved_jobs(self, user: User) -> SavedJobsListResponse:
        records = self.saved_job_repo.list_for_user(user.id)
        saved_jobs = [self._to_saved_job_response(record) for record in records]
        return SavedJobsListResponse(total=len(saved_jobs), saved_jobs=saved_jobs)

    def list_search_history(self, user: User) -> SearchHistoryListResponse:
        records = self.search_history_repo.list_for_user(user.id)
        searches = [SearchHistoryItem.model_validate(record) for record in records]
        return SearchHistoryListResponse(total=len(searches), searches=searches)

    def delete_search_history(self, user: User, search_id: UUID) -> None:
        entry = self.search_history_repo.get_by_id_for_user(user.id, search_id)
        if entry is None:
            raise NotFoundError("Search history entry not found.")
        self.search_history_repo.delete(entry)

    def _to_saved_job_response(self, record) -> SavedJobResponse:
        job_payload = record.job_data
        job = JobPosting(
            job_id=job_payload.get("job_id") or record.external_job_id,
            title=job_payload.get("title", ""),
            company_name=job_payload.get("company_name", ""),
            location=job_payload.get("location", ""),
            description=job_payload.get("description", ""),
            apply_link=job_payload.get("apply_link", ""),
            source_platform=job_payload.get("source_platform", ""),
            posted_date=job_payload.get("posted_date"),
        )
        return SavedJobResponse(
            id=record.id,
            external_job_id=record.external_job_id,
            job=job,
            created_at=record.created_at,
        )
