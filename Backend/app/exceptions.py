"""Application-specific exceptions mapped to HTTP responses."""

from typing import Any, Optional


class AppError(Exception):
    """Base exception for predictable API failures."""

    def __init__(
        self,
        message: str,
        status_code: int = 400,
        details: Optional[Any] = None,
    ) -> None:
        self.message = message
        self.status_code = status_code
        self.details = details
        super().__init__(message)


class NotFoundError(AppError):
    """Resource was not found."""

    def __init__(self, message: str = "Resource not found.") -> None:
        super().__init__(message=message, status_code=404)


class UnauthorizedError(AppError):
    """Authentication failed or credentials are invalid."""

    def __init__(self, message: str = "Could not validate credentials.") -> None:
        super().__init__(message=message, status_code=401)


class ForbiddenError(AppError):
    """Authenticated user lacks permission for the action."""

    def __init__(self, message: str = "Not enough permissions.") -> None:
        super().__init__(message=message, status_code=403)


class ConflictError(AppError):
    """Request conflicts with existing data, e.g. duplicate email."""

    def __init__(self, message: str = "Resource already exists.") -> None:
        super().__init__(message=message, status_code=409)


class ValidationError(AppError):
    """Input failed business validation beyond Pydantic schema checks."""

    def __init__(self, message: str, details: Optional[Any] = None) -> None:
        super().__init__(message=message, status_code=422, details=details)


class ExternalServiceError(AppError):
    """Upstream API such as JSearch returned an error."""

    def __init__(self, message: str = "External service unavailable.") -> None:
        super().__init__(message=message, status_code=502)
