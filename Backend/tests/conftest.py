"""Shared pytest fixtures for API integration tests."""

from pathlib import Path

import pytest
from dotenv import load_dotenv

# Load environment before any app module reads settings.
load_dotenv(Path(__file__).resolve().parents[1] / ".env", override=True)

from fastapi import FastAPI, Request
from fastapi.responses import JSONResponse
from fastapi.testclient import TestClient
from sqlalchemy import create_engine
from sqlalchemy.orm import Session, sessionmaker

from app.config import get_settings

get_settings.cache_clear()

_settings = get_settings()
_database_url = _settings.database_url
if _database_url.startswith("postgresql://"):
    _database_url = _database_url.replace("postgresql://", "postgresql+psycopg2://", 1)

from app.core.security import create_access_token, hash_password
from app.database import get_db
from app.exceptions import AppError
from app.repositories.user_repository import UserRepository
from app.routers import saved_jobs

test_engine = create_engine(_database_url, pool_pre_ping=True)
TestingSessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=test_engine)


def create_test_app() -> FastAPI:
    """Build a minimal app with saved routes and AppError handling."""
    test_app = FastAPI()
    test_app.include_router(saved_jobs.router, prefix="/api/v1")

    @test_app.exception_handler(AppError)
    async def app_error_handler(_: Request, exc: AppError) -> JSONResponse:
        body: dict = {"error": exc.message}
        if exc.details is not None:
            body["details"] = exc.details
        return JSONResponse(status_code=exc.status_code, content=body)

    return test_app


@pytest.fixture
def db() -> Session:
    """Provide a database session rolled back after each test."""
    connection = test_engine.connect()
    transaction = connection.begin()
    session = Session(bind=connection)

    yield session

    session.close()
    transaction.rollback()
    connection.close()


@pytest.fixture
def client(db: Session) -> TestClient:
    """FastAPI test client with database session override."""
    test_app = create_test_app()

    def override_get_db():
        try:
            yield db
        finally:
            pass

    test_app.dependency_overrides[get_db] = override_get_db
    with TestClient(test_app) as test_client:
        yield test_client
    test_app.dependency_overrides.clear()


@pytest.fixture
def auth_headers(db: Session):
    """Create a user and return auth headers plus the user record."""

    def _create_user(email: str, name: str = "Test User"):
        user = UserRepository(db).create(
            email=email,
            hashed_password=hash_password("Test1234"),
            name=name,
        )
        token = create_access_token(str(user.id))
        headers = {"Authorization": f"Bearer {token}"}
        return user, headers

    return _create_user
