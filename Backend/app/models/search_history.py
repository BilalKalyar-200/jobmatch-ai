"""Job search history model."""

import uuid

from sqlalchemy import ForeignKey, String
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base
from app.models.base import GUID, TimestampMixin


class SearchHistory(Base, TimestampMixin):
    """Record of a user's past job search parameters."""

    __tablename__ = "search_history"

    id: Mapped[uuid.UUID] = mapped_column(GUID(), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        GUID(),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    niche: Mapped[str] = mapped_column(String(255), nullable=False)
    country: Mapped[str] = mapped_column(String(10), nullable=False)
    cities: Mapped[list] = mapped_column(JSONB, nullable=False)

    user: Mapped["User"] = relationship("User", back_populates="search_history")


from app.models.user import User  # noqa: E402
