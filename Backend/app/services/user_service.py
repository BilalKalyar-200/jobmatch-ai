"""User profile business logic."""

from sqlalchemy.orm import Session

from app.models.user import User
from app.repositories.user_repository import UserRepository
from app.schemas.user import UserProfileResponse, UserProfileUpdateRequest


class UserService:
    """Profile read and update operations."""

    def __init__(self, db: Session) -> None:
        self.user_repo = UserRepository(db)

    def get_profile(self, user: User) -> UserProfileResponse:
        return UserProfileResponse.model_validate(user)

    def update_profile(self, user: User, payload: UserProfileUpdateRequest) -> UserProfileResponse:
        updates = payload.model_dump(exclude_unset=True)
        if not updates:
            return UserProfileResponse.model_validate(user)

        updated = self.user_repo.update_profile(user, updates)
        return UserProfileResponse.model_validate(updated)
