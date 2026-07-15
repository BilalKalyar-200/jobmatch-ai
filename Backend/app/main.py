"""FastAPI application entry point."""

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from pydantic import ValidationError as PydanticValidationError
from slowapi.errors import RateLimitExceeded
from slowapi.middleware import SlowAPIMiddleware

from app.core.rate_limit import limiter

from app.config import get_settings
from app.exceptions import AppError
from app.routers import auth, jobs, resumes, saved_jobs, users

settings = get_settings()


def create_app() -> FastAPI:
    """Application factory used by uvicorn and deployment platforms."""
    app = FastAPI(
        title=settings.app_name,
        version=settings.app_version,
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
    )

    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )
    app.state.limiter = limiter
    app.add_middleware(SlowAPIMiddleware)

    app.include_router(auth.router, prefix=settings.api_v1_prefix)
    app.include_router(users.router, prefix=settings.api_v1_prefix)
    app.include_router(jobs.router, prefix=settings.api_v1_prefix)
    app.include_router(resumes.router, prefix=settings.api_v1_prefix)
    app.include_router(saved_jobs.router, prefix=settings.api_v1_prefix)

    register_exception_handlers(app)
    register_health_routes(app)

    return app


def register_health_routes(app: FastAPI) -> None:
    """Simple health endpoints for uptime checks on Render, Railway, etc."""

    @app.get("/health", tags=["Health"])
    def health_check() -> dict[str, str]:
        return {"status": "ok"}

    @app.get("/", tags=["Health"])
    def root() -> dict[str, str]:
        return {
            "service": settings.app_name,
            "docs": "/docs",
            "api": settings.api_v1_prefix,
        }


def register_exception_handlers(app: FastAPI) -> None:
    """Convert internal exceptions into clean JSON error responses."""

    def _sanitize_errors(errors: list) -> list:
        """Pydantic v2 puts the raw exception object inside 'ctx' when a
        custom validator raises a plain ValueError (e.g. our password
        strength check). json.dumps cannot serialize an exception object,
        so we convert any Exception found in ctx into a plain string
        before this ever reaches JSONResponse.
        """
        clean_errors = []
        for err in errors:
            err = dict(err)
            if "ctx" in err and isinstance(err["ctx"], dict):
                err["ctx"] = {
                    key: (str(value) if isinstance(value, Exception) else value)
                    for key, value in err["ctx"].items()
                }
            clean_errors.append(err)
        return clean_errors

    @app.exception_handler(AppError)
    async def app_error_handler(_: Request, exc: AppError) -> JSONResponse:
        body: dict = {"error": exc.message}
        if exc.details is not None:
            body["details"] = exc.details
        return JSONResponse(status_code=exc.status_code, content=body)

    @app.exception_handler(RequestValidationError)
    async def request_validation_handler(
        _: Request,
        exc: RequestValidationError,
    ) -> JSONResponse:
        return JSONResponse(
            status_code=422,
            content={
                "error": "Validation failed.",
                "details": _sanitize_errors(exc.errors()),
            },
        )

    @app.exception_handler(PydanticValidationError)
    async def pydantic_validation_handler(
        _: Request,
        exc: PydanticValidationError,
    ) -> JSONResponse:
        return JSONResponse(
            status_code=422,
            content={
                "error": "Validation failed.",
                "details": _sanitize_errors(exc.errors()),
            },
        )
    @app.exception_handler(RateLimitExceeded)
    async def rate_limit_handler(_: Request, exc: RateLimitExceeded) -> JSONResponse:
        return JSONResponse(
            status_code=429,
            content={"error": "Too many requests. Please try again shortly."},
        )
    @app.exception_handler(Exception)
    async def unhandled_exception_handler(_: Request, exc: Exception) -> JSONResponse:
        # Log internally in production. Never expose raw tracebacks to clients.
        if settings.debug:
            detail = str(exc)
            # Belt and suspenders check. This should never legitimately
            # happen, but guarantees the JWT secret can never leak through
            # an unrelated exception message.
            if settings.jwt_secret_key in detail:
                detail = "[redacted]"
            return JSONResponse(
                status_code=500,
                content={"error": "Internal server error.", "details": detail},
            )
        return JSONResponse(
            status_code=500,
            content={"error": "Internal server error."},
        )


app = create_app()
