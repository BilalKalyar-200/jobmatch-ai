"""Tests for keyword extraction."""

from app.core.matching.keyword_extractor import extract_keywords


SAMPLE_JOB_DESCRIPTION = """
We are seeking a backend engineer with strong Python and FastAPI experience.
The ideal candidate is expected to work closely with the team while building
APIs backed by PostgreSQL and Redis. Responsibilities include ensuring services
are deployed with Docker and resolving issues promptly. 3+ years experience required.
"""


def test_extract_keywords_includes_real_skills():
    keywords = extract_keywords(SAMPLE_JOB_DESCRIPTION)

    assert "python" in keywords
    assert "fastapi" in keywords
    assert "postgresql" in keywords
    assert "redis" in keywords
    assert "docker" in keywords


def test_extract_keywords_excludes_filler_words():
    keywords = extract_keywords(SAMPLE_JOB_DESCRIPTION)

    filler_words = {
        "candidate",
        "expected",
        "closely",
        "seeking",
        "ideal",
        "promptly",
        "ensuring",
        "resolving",
        "while",
    }
    assert filler_words.isdisjoint(keywords)


def test_extract_keywords_includes_requirement_phrases():
    keywords = extract_keywords(SAMPLE_JOB_DESCRIPTION)

    assert "3+ years experience" in keywords
