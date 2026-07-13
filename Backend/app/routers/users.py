"""User profile routes."""

from fastapi import APIRouter

from app.dependencies import CurrentUser, DbSession
from app.schemas.user import UserProfileResponse, UserProfileUpdateRequest
from app.services.user_service import UserService

router = APIRouter(prefix="/users", tags=["Users"])


@router.get("/me", response_model=UserProfileResponse)
def get_my_profile(current_user: CurrentUser, db: DbSession) -> UserProfileResponse:
    """Return the authenticated user's profile."""
    return UserService(db).get_profile(current_user)


@router.patch("/me", response_model=UserProfileResponse)
def update_my_profile(
    payload: UserProfileUpdateRequest,
    current_user: CurrentUser,
    db: DbSession,
) -> UserProfileResponse:
    """Update profile fields such as name and location preferences."""
    return UserService(db).update_profile(current_user, payload)
