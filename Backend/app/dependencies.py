
"""FastAPI dependency injection helpers."""

from typing import Annotated
from uuid import UUID

from fastapi import Depends, HTTPException, status
from fastapi.security import HTTPAuthorizationCredentials, HTTPBearer
from jose import JWTError
from sqlalchemy.orm import Session

from app.core.security import decode_token
from app.database import get_db
from app.exceptions import UnauthorizedError
from app.models.user import User
from app.repositories.user_repository import UserRepository

bearer_scheme = HTTPBearer(auto_error=False)

DbSession = Annotated[Session, Depends(get_db)]


def get_current_user(
    db: DbSession,
    credentials: Annotated[HTTPAuthorizationCredentials | None, Depends(bearer_scheme)],
) -> User:
    """
    Resolve the authenticated user from a Bearer access token.

    Routes stay thin by depending on this function instead of parsing JWT manually.
    """
    if credentials is None or credentials.scheme.lower() != "bearer":
        raise UnauthorizedError("Missing or invalid authorization header.")

    try:
        payload = decode_token(credentials.credentials)
    except JWTError as exc:
        raise UnauthorizedError("Could not validate credentials.") from exc

    if payload.get("type") != "access":
        raise UnauthorizedError("Invalid token type.")

    subject = payload.get("sub")
    if not subject:
        raise UnauthorizedError("Token subject missing.")

    user = UserRepository(db).get_by_id(UUID(subject))
    if user is None:
        raise UnauthorizedError("User not found.")

    return user


CurrentUser = Annotated[User, Depends(get_current_user)]
