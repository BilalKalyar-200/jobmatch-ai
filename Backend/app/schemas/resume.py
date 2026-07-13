"""Resume upload schemas."""

from datetime import datetime
from typing import Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, Field


class ResumeResponse(BaseModel):
    """Stored resume metadata. Parsed text is not returned in full by default."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    filename: str
    text_preview: str = Field(description="First 500 characters of parsed resume text.")
    created_at: datetime
    updated_at: datetime


class ResumeUploadResponse(BaseModel):
    """Response after a successful resume upload."""

    resume: ResumeResponse
    message: str = "Resume uploaded and parsed successfully."
