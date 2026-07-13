"""Semantic similarity scoring with local sentence embeddings."""

from functools import lru_cache
from typing import TYPE_CHECKING

if TYPE_CHECKING:
    import numpy as np
    from sentence_transformers import SentenceTransformer


@lru_cache(maxsize=1)
def _get_model() -> "SentenceTransformer":
    """
    Load the embedding model once per process.

    all-MiniLM-L6-v2 is small, fast, and runs fully locally with no external API.
    Imports are deferred so the API can boot before the model is first needed.
    """
    from sentence_transformers import SentenceTransformer

    return SentenceTransformer("all-MiniLM-L6-v2")


def _cosine_similarity(vector_a: "np.ndarray", vector_b: "np.ndarray") -> float:
    """Return cosine similarity mapped to the 0-100 range."""
    import numpy as np

    denominator = np.linalg.norm(vector_a) * np.linalg.norm(vector_b)
    if denominator == 0:
        return 0.0
    cosine = float(np.dot(vector_a, vector_b) / denominator)
    # Cosine for normalized embeddings is in [-1, 1]; map to [0, 100].
    return max(0.0, min(100.0, ((cosine + 1.0) / 2.0) * 100.0))


def compute_semantic_score(resume_text: str, job_description: str) -> float:
    """
    Embed resume and job description, then score their semantic similarity.

    Returns a float from 0 to 100.
    """
    model = _get_model()
    embeddings = model.encode(
        [resume_text, job_description],
        convert_to_numpy=True,
        normalize_embeddings=True,
    )
    return _cosine_similarity(embeddings[0], embeddings[1])
