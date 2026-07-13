"""Saved job persistence."""

from typing import List, Optional
from uuid import UUID

from sqlalchemy.orm import Session

from app.models.saved_job import SavedJob


class SavedJobRepository:
    """CRUD helpers for bookmarked jobs."""

    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_user_and_job_id(self, user_id: UUID, external_job_id: str) -> Optional[SavedJob]:
        return (
            self.db.query(SavedJob)
            .filter(
                SavedJob.user_id == user_id,
                SavedJob.external_job_id == external_job_id,
            )
            .first()
        )

    def list_for_user(self, user_id: UUID) -> List[SavedJob]:
        return (
            self.db.query(SavedJob)
            .filter(SavedJob.user_id == user_id)
            .order_by(SavedJob.created_at.desc())
            .all()
        )

    def create(self, user_id: UUID, external_job_id: str, job_data: dict) -> SavedJob:
        saved = SavedJob(
            user_id=user_id,
            external_job_id=external_job_id,
            job_data=job_data,
        )
        self.db.add(saved)
        self.db.commit()
        self.db.refresh(saved)
        return saved

    def delete(self, saved_job: SavedJob) -> None:
        self.db.delete(saved_job)
        self.db.commit()
