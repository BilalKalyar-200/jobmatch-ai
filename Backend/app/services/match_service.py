"""Resume to job match orchestration."""

from sqlalchemy.orm import Session

from app.config import get_settings
from app.core.matching.scorer import score_resume_against_job
from app.exceptions import ValidationError
from app.models.user import User
from app.schemas.job import JobMatchRequest, JobMatchResponse
from app.services.job_search_service import JobSearchService
from app.services.resume_service import ResumeService

settings = get_settings()


class MatchService:
    """Coordinates resume retrieval, job description resolution, and scoring."""

    def __init__(self, db: Session) -> None:
        self.resume_service = ResumeService(db)
        self.job_search_service = JobSearchService(db)

    async def score_match(self, user: User, payload: JobMatchRequest) -> JobMatchResponse:
        if not payload.job_id and not payload.job_description:
            raise ValidationError("Provide either job_id or job_description.")

        resume_text = self.resume_service.get_resume_text_for_user(user)

        if payload.job_description:
            job_description = payload.job_description
        else:
            job_description = await self.job_search_service.get_job_description_by_id(
                payload.job_id  # type: ignore[arg-type]
            )

        result = score_resume_against_job(resume_text, job_description)
        formula = (
            f"final_score = ({settings.keyword_score_weight} * keyword_score) + "
            f"({settings.semantic_score_weight} * semantic_score)"
        )

        return JobMatchResponse(
            final_score=result.final_score,
            keyword_score=result.keyword_score,
            semantic_score=result.semantic_score,
            matched_keywords=result.matched_keywords,
            missing_keywords=result.missing_keywords,
            scoring_formula=formula,
        )
