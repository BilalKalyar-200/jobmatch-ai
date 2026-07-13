"""Authentication business logic."""

from datetime import datetime, timezone
from uuid import UUID

from jose import JWTError
from sqlalchemy.orm import Session

from app.core.security import (
    create_access_token,
    create_refresh_token,
    decode_token,
    hash_password,
    verify_password,
)
from app.exceptions import ConflictError, UnauthorizedError
from app.repositories.user_repository import UserRepository
from app.schemas.auth import LoginRequest, SignupRequest, TokenResponse


class AuthService:
    """Handles signup, login, refresh, and logout flows."""

    def __init__(self, db: Session) -> None:
        self.user_repo = UserRepository(db)

    def signup(self, payload: SignupRequest) -> TokenResponse:
        if self.user_repo.get_by_email(payload.email):
            raise ConflictError("Email is already registered.")

        user = self.user_repo.create(
            email=payload.email,
            hashed_password=hash_password(payload.password),
            name=payload.name,
        )
        return self._issue_tokens(str(user.id))

    def login(self, payload: LoginRequest) -> TokenResponse:
        user = self.user_repo.get_by_email(payload.email)
        if user is None or not verify_password(payload.password, user.hashed_password):
            raise UnauthorizedError("Invalid email or password.")

        return self._issue_tokens(str(user.id))

    def refresh(self, refresh_token: str) -> TokenResponse:
        try:
            payload = decode_token(refresh_token)
        except JWTError as exc:
            raise UnauthorizedError("Invalid refresh token.") from exc

        if payload.get("type") != "refresh":
            raise UnauthorizedError("Invalid refresh token type.")

        token_jti = payload.get("jti")
        subject = payload.get("sub")
        if not token_jti or not subject:
            raise UnauthorizedError("Malformed refresh token.")

        stored = self.user_repo.get_refresh_token_by_jti(token_jti)
        if stored is None:
            raise UnauthorizedError("Refresh token revoked or unknown.")

        if stored.expires_at < datetime.now(timezone.utc):
            self.user_repo.delete_refresh_token(stored)
            raise UnauthorizedError("Refresh token expired.")

        # Rotate refresh tokens so a stolen token has a short useful lifetime.
        self.user_repo.delete_refresh_token(stored)
        return self._issue_tokens(subject)

    def logout(self, refresh_token: str) -> None:
        try:
            payload = decode_token(refresh_token)
        except JWTError:
            return

        token_jti = payload.get("jti")
        if not token_jti:
            return

        stored = self.user_repo.get_refresh_token_by_jti(token_jti)
        if stored:
            self.user_repo.delete_refresh_token(stored)

    def _issue_tokens(self, user_id: str) -> TokenResponse:
        access_token = create_access_token(user_id)
        refresh_token = create_refresh_token(user_id)
        refresh_payload = decode_token(refresh_token)
        expires_at = datetime.fromtimestamp(refresh_payload["exp"], tz=timezone.utc)
        self.user_repo.save_refresh_token(
            user_id=UUID(user_id),
            token_jti=refresh_payload["jti"],
            expires_at=expires_at,
        )
        return TokenResponse(access_token=access_token, refresh_token=refresh_token)
