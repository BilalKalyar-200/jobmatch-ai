"""User and refresh token persistence."""

from datetime import datetime
from typing import Optional
from uuid import UUID

from sqlalchemy.orm import Session

from app.models.user import RefreshToken, User


class UserRepository:
    """CRUD helpers for users and refresh tokens."""

    def __init__(self, db: Session) -> None:
        self.db = db

    def get_by_email(self, email: str) -> Optional[User]:
        return self.db.query(User).filter(User.email == email.lower()).first()

    def get_by_id(self, user_id: UUID) -> Optional[User]:
        return self.db.query(User).filter(User.id == user_id).first()

    def create(self, email: str, hashed_password: str, name: str) -> User:
        user = User(
            email=email.lower(),
            hashed_password=hashed_password,
            name=name,
            preferred_niches=[],
            preferred_countries=[],
            preferred_cities=[],
        )
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user

    def update_profile(self, user: User, updates: dict) -> User:
        for field, value in updates.items():
            if value is not None:
                setattr(user, field, value)
        self.db.add(user)
        self.db.commit()
        self.db.refresh(user)
        return user

    def save_refresh_token(self, user_id: UUID, token_jti: str, expires_at: datetime) -> RefreshToken:
        token = RefreshToken(
            user_id=user_id,
            token_jti=token_jti,
            expires_at=expires_at,
        )
        self.db.add(token)
        self.db.commit()
        self.db.refresh(token)
        return token

    def get_refresh_token_by_jti(self, token_jti: str) -> Optional[RefreshToken]:
        return self.db.query(RefreshToken).filter(RefreshToken.token_jti == token_jti).first()

    def delete_refresh_token(self, token: RefreshToken) -> None:
        self.db.delete(token)
        self.db.commit()

    def delete_refresh_tokens_for_user(self, user_id: UUID) -> None:
        self.db.query(RefreshToken).filter(RefreshToken.user_id == user_id).delete()
        self.db.commit()
