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


ML_SAMPLE_JOB_DESCRIPTION = """
We are looking for a talented Python Developer with strong expertise
in Artificial Intelligence and Machine Learning. This role involves
developing scalable AI ML solutions, building efficient data pipelines,
and contributing to end to end machine learning workflows. Strong
proficiency in Python and core libraries such as NumPy, Pandas, and
Scikit-learn is required. Experience with REST APIs and cross
functional collaboration is a plus.
"""


def test_extract_keywords_includes_curated_phrases_not_junk_bigrams():
    keywords = extract_keywords(ML_SAMPLE_JOB_DESCRIPTION)

    assert "machine learning" in keywords
    assert "rest apis" in keywords

    junk_fragments = {
        "learning workflows.",
        "talented python",
        "perform data",
        "learning ml",
        "learning frameworks",
    }
    assert junk_fragments.isdisjoint(keywords)
