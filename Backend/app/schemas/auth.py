"""Authentication schemas."""

import re
from typing import Optional

from pydantic import BaseModel, EmailStr, Field, field_validator


class SignupRequest(BaseModel):
    """Payload for user registration."""

    email: EmailStr
    password: str = Field(min_length=8, max_length=128)
    name: str = Field(min_length=1, max_length=255)

    @field_validator("password")
    @classmethod
    def validate_password_strength(cls, value: str) -> str:
        """Require mixed character classes to reduce weak credential risk."""
        if not re.search(r"[A-Za-z]", value) or not re.search(r"\d", value):
            raise ValueError("Password must contain at least one letter and one number.")
        return value


class LoginRequest(BaseModel):
    """Payload for email and password login."""

    email: EmailStr
    password: str = Field(min_length=1, max_length=128)


class RefreshRequest(BaseModel):
    """Payload for exchanging a refresh token for new tokens."""

    refresh_token: str = Field(min_length=10)


class TokenResponse(BaseModel):
    """JWT pair returned after login, signup, or refresh."""

    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class MessageResponse(BaseModel):
    """Simple message response for logout and similar actions."""

    message: str
