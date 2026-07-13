"""Search history persistence."""

from typing import List
from uuid import UUID

from sqlalchemy.orm import Session

from app.models.search_history import SearchHistory


class SearchHistoryRepository:
    """CRUD helpers for job search history."""

    def __init__(self, db: Session) -> None:
        self.db = db

    def create(self, user_id: UUID, niche: str, country: str, cities: list[str]) -> SearchHistory:
        entry = SearchHistory(
            user_id=user_id,
            niche=niche,
            country=country.lower(),
            cities=cities,
        )
        self.db.add(entry)
        self.db.commit()
        self.db.refresh(entry)
        return entry

    def list_for_user(self, user_id: UUID, limit: int = 50) -> List[SearchHistory]:
        return (
            self.db.query(SearchHistory)
            .filter(SearchHistory.user_id == user_id)
            .order_by(SearchHistory.created_at.desc())
            .limit(limit)
            .all()
        )
