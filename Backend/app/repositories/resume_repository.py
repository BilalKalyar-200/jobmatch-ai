"""Resume persistence."""

from typing import Optional
from uuid import UUID

from sqlalchemy.orm import Session

from app.models.resume import Resume


class ResumeRepository:
    """CRUD helpers for user resumes."""

    def __init__(self, db: Session) -> None:
        self.db = db

    def get_latest_for_user(self, user_id: UUID) -> Optional[Resume]:
        return (
            self.db.query(Resume)
            .filter(Resume.user_id == user_id)
            .order_by(Resume.updated_at.desc())
            .first()
        )

    def get_by_id_for_user(self, resume_id: UUID, user_id: UUID) -> Optional[Resume]:
        return (
            self.db.query(Resume)
            .filter(Resume.id == resume_id, Resume.user_id == user_id)
            .first()
        )

    def upsert_for_user(self, user_id: UUID, filename: str, parsed_text: str) -> Resume:
        """
        Store one active resume per user by updating the latest record or creating one.

        This keeps match scoring simple for mobile and web clients.
        """
        existing = self.get_latest_for_user(user_id)
        if existing:
            existing.filename = filename
            existing.parsed_text = parsed_text
            self.db.add(existing)
            self.db.commit()
            self.db.refresh(existing)
            return existing

        resume = Resume(user_id=user_id, filename=filename, parsed_text=parsed_text)
        self.db.add(resume)
        self.db.commit()
        self.db.refresh(resume)
        return resume
