"""Authentication routes."""

from fastapi import APIRouter, Request, status

from app.core.rate_limit import limiter
from app.dependencies import DbSession
from app.schemas.auth import (
    LoginRequest,
    MessageResponse,
    RefreshRequest,
    SignupRequest,
    TokenResponse,
)
from app.services.auth_service import AuthService

router = APIRouter(prefix="/auth", tags=["Auth"])


@router.post("/signup", response_model=TokenResponse, status_code=status.HTTP_201_CREATED)
@limiter.limit("3/minute")
def signup(request: Request, payload: SignupRequest, db: DbSession) -> TokenResponse:
    """Register a new user and return JWT tokens."""
    return AuthService(db).signup(payload)


@router.post("/login", response_model=TokenResponse)
@limiter.limit("5/minute")
def login(request: Request, payload: LoginRequest, db: DbSession) -> TokenResponse:
    """Authenticate with email and password."""
    return AuthService(db).login(payload)


@router.post("/refresh", response_model=TokenResponse)
def refresh_tokens(payload: RefreshRequest, db: DbSession) -> TokenResponse:
    """Exchange a valid refresh token for a new token pair."""
    return AuthService(db).refresh(payload.refresh_token)


@router.post("/logout", response_model=MessageResponse)
def logout(payload: RefreshRequest, db: DbSession) -> MessageResponse:
    """Revoke the provided refresh token."""
    AuthService(db).logout(payload.refresh_token)
    return MessageResponse(message="Logged out successfully.")