"""Resume upload routes."""

from fastapi import APIRouter, File, UploadFile, status

from app.dependencies import CurrentUser, DbSession
from app.schemas.resume import ResumeResponse, ResumeUploadResponse
from app.services.resume_service import ResumeService

router = APIRouter(prefix="/resumes", tags=["Resumes"])


@router.post(
    "/upload",
    response_model=ResumeUploadResponse,
    status_code=status.HTTP_201_CREATED,
)
async def upload_resume(
    current_user: CurrentUser,
    db: DbSession,
    file: UploadFile = File(...),
) -> ResumeUploadResponse:
    """Upload a PDF or DOCX resume, parse text, and store it for the user."""
    return await ResumeService(db).upload_resume(current_user, file)


@router.get("/me", response_model=ResumeResponse)
def get_my_resume(current_user: CurrentUser, db: DbSession) -> ResumeResponse:
    """Return metadata and a short preview of the user's latest resume."""
    return ResumeService(db).get_latest_resume(current_user)
