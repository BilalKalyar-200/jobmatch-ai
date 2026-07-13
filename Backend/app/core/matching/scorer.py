"""
Resume to job match scoring.

Final score formula (configurable via environment weights):
    final_score = (keyword_weight * keyword_score) + (semantic_weight * semantic_score)

Default weights:
    keyword_score_weight = 0.4
    semantic_score_weight = 0.6

Keyword score:
    keyword_score = (|resume_keywords INTERSECT job_keywords| / |job_keywords|) * 100
    If the job description yields no keywords, keyword_score is 0.

Semantic score:
    Cosine similarity between sentence embeddings of the full resume text and
    full job description, mapped to 0-100. See semantic_scorer.py.

The module is intentionally independent from FastAPI routes so the algorithm
can evolve without touching HTTP handlers.
"""

from dataclasses import dataclass
from typing import List, Set

from app.config import get_settings
from app.core.matching.keyword_extractor import extract_keywords
from app.core.matching.semantic_scorer import compute_semantic_score

settings = get_settings()


@dataclass
class MatchResult:
    """Structured output from the matching engine."""

    final_score: float
    keyword_score: float
    semantic_score: float
    matched_keywords: List[str]
    missing_keywords: List[str]


def _keyword_overlap_score(resume_keywords: Set[str], job_keywords: Set[str]) -> tuple[float, List[str], List[str]]:
    """Compute percentage of job keywords present in the resume."""
    if not job_keywords:
        return 0.0, [], []

    matched = sorted(resume_keywords & job_keywords)
    missing = sorted(job_keywords - resume_keywords)
    score = (len(matched) / len(job_keywords)) * 100.0
    return score, matched, missing


def score_resume_against_job(resume_text: str, job_description: str) -> MatchResult:
    """
    Compare one resume against one job description and return a composite score.

    Args:
        resume_text: Parsed plain text from the user's resume.
        job_description: Full job description text from JSearch or client input.

    Returns:
        MatchResult with final score, component scores, and keyword gaps.
    """
    resume_keywords = extract_keywords(resume_text)
    job_keywords = extract_keywords(job_description)

    keyword_score, matched_keywords, missing_keywords = _keyword_overlap_score(
        resume_keywords,
        job_keywords,
    )
    semantic_score = compute_semantic_score(resume_text, job_description)

    final_score = (
        settings.keyword_score_weight * keyword_score
        + settings.semantic_score_weight * semantic_score
    )
    final_score = round(max(0.0, min(100.0, final_score)), 2)

    return MatchResult(
        final_score=final_score,
        keyword_score=round(keyword_score, 2),
        semantic_score=round(semantic_score, 2),
        matched_keywords=matched_keywords,
        missing_keywords=missing_keywords,
    )
