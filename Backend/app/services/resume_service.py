"""Resume upload and parsing business logic."""

import io

from docx import Document
from fastapi import UploadFile
from pypdf import PdfReader
from sqlalchemy.orm import Session

from app.config import get_settings
from app.exceptions import NotFoundError, ValidationError
from app.models.user import User
from app.repositories.resume_repository import ResumeRepository
from app.schemas.resume import ResumeResponse, ResumeUploadResponse

settings = get_settings()

ALLOWED_CONTENT_TYPES = {
    "application/pdf": "pdf",
    "application/vnd.openxmlformats-officedocument.wordprocessingml.document": "docx",
}
ALLOWED_EXTENSIONS = {".pdf", ".docx"}


class ResumeService:
    """Handles resume file validation, parsing, and persistence."""

    def __init__(self, db: Session) -> None:
        self.resume_repo = ResumeRepository(db)

    async def upload_resume(self, user: User, file: UploadFile) -> ResumeUploadResponse:
            filename = file.filename or "resume"
            extension = self._validate_file(filename, file.content_type)

            # Read at most one byte more than the allowed size. This avoids
            # buffering an unbounded upload fully into memory before the size
            # check below can reject it, protecting against large file abuse.
            max_bytes = settings.max_resume_size_bytes
            content = await file.read(max_bytes + 1)

            if len(content) > max_bytes:
                raise ValidationError(
                    f"Resume exceeds maximum size of {settings.max_resume_size_mb} MB."
                )
            if len(content) == 0:
                raise ValidationError("Uploaded file is empty.")

            parsed_text = self._extract_text(content, extension)
            if not parsed_text.strip():
                raise ValidationError("Could not extract text from the uploaded resume.")

            resume = self.resume_repo.upsert_for_user(
                user_id=user.id,
                filename=filename,
                parsed_text=parsed_text,
            )
            return ResumeUploadResponse(resume=self._to_response(resume))

    def get_latest_resume(self, user: User) -> ResumeResponse:
        resume = self.resume_repo.get_latest_for_user(user.id)
        if resume is None:
            raise NotFoundError("No resume found. Upload a resume first.")
        return self._to_response(resume)

    def get_resume_text_for_user(self, user: User) -> str:
        resume = self.resume_repo.get_latest_for_user(user.id)
        if resume is None:
            raise NotFoundError("No resume found. Upload a resume first.")
        return resume.parsed_text

    def _validate_file(self, filename: str, content_type: str | None) -> str:
        lower_name = filename.lower()
        if not any(lower_name.endswith(ext) for ext in ALLOWED_EXTENSIONS):
            raise ValidationError("Only PDF and DOCX files are supported.")

        if content_type and content_type not in ALLOWED_CONTENT_TYPES:
            # Some clients send generic octet-stream, so extension check is authoritative.
            if content_type != "application/octet-stream":
                raise ValidationError("Only PDF and DOCX files are supported.")

        if lower_name.endswith(".pdf"):
            return "pdf"
        return "docx"

    def _extract_text(self, content: bytes, extension: str) -> str:
        if extension == "pdf":
            return self._extract_pdf_text(content)
        return self._extract_docx_text(content)

    def _extract_pdf_text(self, content: bytes) -> str:
        reader = PdfReader(io.BytesIO(content))
        pages = [page.extract_text() or "" for page in reader.pages]
        return "\n".join(pages)

    def _extract_docx_text(self, content: bytes) -> str:
        document = Document(io.BytesIO(content))
        paragraphs = [paragraph.text for paragraph in document.paragraphs if paragraph.text]
        return "\n".join(paragraphs)

    def _to_response(self, resume) -> ResumeResponse:
        preview = resume.parsed_text[:500]
        return ResumeResponse(
            id=resume.id,
            filename=resume.filename,
            text_preview=preview,
            created_at=resume.created_at,
            updated_at=resume.updated_at,
        )
