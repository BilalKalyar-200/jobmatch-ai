"""User profile schemas."""

from datetime import datetime
from typing import List, Optional
from uuid import UUID

from pydantic import BaseModel, ConfigDict, EmailStr, Field


class UserProfileResponse(BaseModel):
    """Public user profile returned to authenticated clients."""

    model_config = ConfigDict(from_attributes=True)

    id: UUID
    email: EmailStr
    name: str
    preferred_niches: List[str]
    preferred_countries: List[str]
    preferred_cities: List[str]
    created_at: datetime
    updated_at: datetime


class UserProfileUpdateRequest(BaseModel):
    """Fields clients may update on their profile."""

    name: Optional[str] = Field(default=None, min_length=1, max_length=255)
    preferred_niches: Optional[List[str]] = None
    preferred_countries: Optional[List[str]] = None
    preferred_cities: Optional[List[str]] = None
