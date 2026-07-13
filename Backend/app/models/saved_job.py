"""Saved job bookmark model."""

import uuid

from sqlalchemy import ForeignKey, String, UniqueConstraint
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base
from app.models.base import GUID, TimestampMixin


class SavedJob(Base, TimestampMixin):
    """A job posting bookmarked by a user."""

    __tablename__ = "saved_jobs"
    __table_args__ = (
        UniqueConstraint("user_id", "external_job_id", name="uq_user_external_job"),
    )

    id: Mapped[uuid.UUID] = mapped_column(GUID(), primary_key=True, default=uuid.uuid4)
    user_id: Mapped[uuid.UUID] = mapped_column(
        GUID(),
        ForeignKey("users.id", ondelete="CASCADE"),
        nullable=False,
        index=True,
    )
    external_job_id: Mapped[str] = mapped_column(String(255), nullable=False, index=True)
    job_data: Mapped[dict] = mapped_column(JSONB, nullable=False)

    user: Mapped["User"] = relationship("User", back_populates="saved_jobs")


from app.models.user import User  # noqa: E402
