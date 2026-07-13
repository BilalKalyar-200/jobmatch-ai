"""Keyword and phrase extraction for resumes and job descriptions."""

import re
from typing import Iterable, Set

# Common English stopwords kept small on purpose for predictable behavior.
STOPWORDS: Set[str] = {
    "a", "an", "and", "are", "as", "at", "be", "by", "for", "from", "has", "have",
    "in", "is", "it", "of", "on", "or", "that", "the", "to", "was", "will", "with",
    "you", "your", "our", "we", "they", "their", "this", "these", "those", "such",
    "able", "about", "all", "any", "can", "may", "must", "should", "would", "could",
    "including", "include", "includes", "required", "requirements", "requirement",
    "experience", "years", "year", "work", "working", "role", "position", "job",
    "team", "company", "using", "use", "used", "strong", "excellent", "good",
}

# Curated skill seeds improve overlap detection beyond generic tokenization.
SKILL_SEEDS: Set[str] = {
    "python", "java", "javascript", "typescript", "react", "angular", "vue", "node",
    "nodejs", "fastapi", "django", "flask", "spring", "kotlin", "swift", "flutter",
    "dart", "golang", "rust", "csharp", "dotnet", "sql", "postgresql", "mysql",
    "mongodb", "redis", "docker", "kubernetes", "aws", "azure", "gcp", "terraform",
    "ansible", "jenkins", "git", "github", "gitlab", "ci", "cd", "agile", "scrum",
    "rest", "graphql", "api", "microservices", "machine", "learning", "deep",
    "tensorflow", "pytorch", "pandas", "numpy", "scikit", "nlp", "llm", "openai",
    "html", "css", "sass", "tailwind", "bootstrap", "linux", "unix", "bash",
    "powershell", "excel", "tableau", "power", "bi", "salesforce", "sap", "oracle",
    "jira", "confluence", "figma", "photoshop", "seo", "sem", "marketing", "sales",
    "communication", "leadership", "management", "analytics", "data", "science",
    "statistics", "testing", "qa", "selenium", "cypress", "jest", "pytest", "junit",
    "security", "oauth", "jwt", "encryption", "blockchain", "solidity", "ethereum",
}

# Requirement phrases often appear verbatim in postings.
REQUIREMENT_PATTERNS: list[re.Pattern[str]] = [
    re.compile(r"\b\d+\+?\s*years?\s+(?:of\s+)?experience\b", re.IGNORECASE),
    re.compile(r"\b(?:bachelor|master|phd|degree)\b", re.IGNORECASE),
    re.compile(r"\b(?:certified|certification)\b", re.IGNORECASE),
    re.compile(r"\b(?:remote|hybrid|onsite|on-site)\b", re.IGNORECASE),
    re.compile(r"\b(?:full[\s-]?time|part[\s-]?time|contract|internship)\b", re.IGNORECASE),
]


def _normalize_text(text: str) -> str:
    """Lowercase and collapse whitespace for consistent tokenization."""
    text = text.lower()
    text = re.sub(r"[^\w\s+#./-]", " ", text)
    text = re.sub(r"\s+", " ", text).strip()
    return text


def _tokenize(text: str) -> list[str]:
    """Split normalized text into candidate keywords."""
    return [token for token in text.split() if len(token) > 1]


def _extract_skill_tokens(tokens: Iterable[str]) -> Set[str]:
    """Keep tokens that look like skills or are in the curated seed list."""
    found: Set[str] = set()
    for token in tokens:
        cleaned = token.strip(".,")
        if cleaned in STOPWORDS:
            continue
        if cleaned in SKILL_SEEDS:
            found.add(cleaned)
            continue
        # Accept alphanumeric tokens with tech markers such as c++, node.js, c#.
        if re.fullmatch(r"[a-z0-9+#./-]{2,}", cleaned):
            if any(marker in cleaned for marker in ("+", "#", ".", "-")) or len(cleaned) >= 3:
                found.add(cleaned)
    return found


def _extract_phrases(text: str) -> Set[str]:
    """Capture requirement phrases and bigrams that often denote skills."""
    phrases: Set[str] = set()
    for pattern in REQUIREMENT_PATTERNS:
        for match in pattern.findall(text):
            phrases.add(match.lower().strip())
    tokens = _tokenize(_normalize_text(text))
    for index in range(len(tokens) - 1):
        first, second = tokens[index], tokens[index + 1]
        if first in STOPWORDS or second in STOPWORDS:
            continue
        if first in SKILL_SEEDS or second in SKILL_SEEDS:
            phrases.add(f"{first} {second}")
    return phrases


def extract_keywords(text: str) -> Set[str]:
    """
    Extract keywords and short phrases from resume or job description text.

    The extractor combines token-based skill detection with regex phrase matching
    so the overlap score reflects both explicit skills and stated requirements.
    """
    normalized = _normalize_text(text)
    tokens = _tokenize(normalized)
    keywords = _extract_skill_tokens(tokens)
    keywords.update(_extract_phrases(text))
    return keywords
