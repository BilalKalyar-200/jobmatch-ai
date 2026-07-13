"""User and refresh token models."""

import uuid
from datetime import datetime

from sqlalchemy import DateTime, ForeignKey, String
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base
from app.models.base import GUID, TimestampMixin, utcnow


class User(Base, TimestampMixin):
    """Registered JobMatch user with profile preferences."""

    __tablename__ = "users"

    id: Mapped[uuid.UUID] = mapped_column(GUID(), primary_key=True, default=uuid.uuid4)
    email: Mapped[str] = mapped_column(String(255), unique=True, index=True, nullable=False)
    hashed_password: Mapped[str] = mapped_column(String(255), nullable=False)
    name: Mapped[str] = mapped_column(String(255), nullable=False)

    # JSON arrays keep niche and location preferences flexible without extra tables.
    preferred_niches: Mapped[list] = mapped_column(JSONB, default=list, nullable=False)
    preferred_countries: Mapped[list] = mapped_column(JSONB, default=list, nullable=False)
    preferred_cities: Mapped[list] = mapped_column(JSONB, default=list, nullable=False)

    resumes: Mapped[list["Resume"]] = relationship(
        "Resume",
        back_populates="user",
        cascade="all, delete-orphan",
    )
    saved_jobs: Mapped[list["SavedJob"]] = relationship(
        "SavedJob",
        back_populates="user",
        cascade="all, delete-orphan",
    )
    search_history: Mapped[list["SearchHistory"]] = relationship(
        "SearchHistory",
        back_populates="user",
        cascade="all, delete-orphan",
    )
    refresh_tokens: Mapped[list["RefreshToken"]] = relationship(
        "RefreshToken",
        back_populates="user",
        cascade="all, delete-orphan",
    )


class RefreshToken(Base):
    """Persisted refresh token metadata for revocation and rotation."""

    __tablename__ = "refresh_tokens"

    id: Mapped[uuid.UUID] = mapped_column(GUID(), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        GUID(),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    token_jti: Mapped[str] = mapped_column(String(64), unique=True, nullable=False)
    expires_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), nullable=False)
    created_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=utcnow,
        nullable=False,
    )

    user: Mapped["User"] = relationship("User", back_populates="refresh_tokens")


# Import after class definitions to satisfy type hints without circular imports at runtime.
from app.models.resume import Resume  # noqa: E402
from app.models.saved_job import SavedJob  # noqa: E402
from app.models.search_history import SearchHistory  # noqa: E402
