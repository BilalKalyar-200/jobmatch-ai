"""Keyword and phrase extraction for resumes and job descriptions."""

import re
from typing import Iterable, Set

# Common English stopwords and job-posting filler kept out of skill detection.
STOPWORDS: Set[str] = {
    "a", "an", "and", "are", "as", "at", "be", "by", "for", "from", "has", "have",
    "in", "is", "it", "of", "on", "or", "that", "the", "to", "was", "will", "with",
    "you", "your", "our", "we", "they", "their", "this", "these", "those", "such",
    "able", "about", "all", "any", "can", "may", "must", "should", "would", "could",
    "including", "include", "includes", "required", "requirements", "requirement",
    "experience", "years", "year", "work", "working", "role", "position", "job",
    "team", "company", "using", "use", "used", "strong", "excellent", "good",
    "seeking", "ideal", "looking", "skilled", "understanding", "valued", "critical",
    "offers", "monthly", "salary", "competitive", "closely", "ensuring", "resolving",
    "promptly", "previous", "more", "while", "expected", "candidate", "candidates",
    "join", "help", "build", "support", "drive", "deliver", "ensure", "provide",
    "ability", "responsible", "responsibilities", "duties", "tasks", "environment",
    "opportunity", "opportunities", "benefits", "culture", "dynamic", "fast",
    "paced", "global", "leading", "innovative", "passionate", "motivated",
    "detail", "oriented", "self", "starter", "highly", "well", "both", "within",
    "across", "between", "through", "during", "after", "before", "each", "every",
    "other", "another", "same", "different", "new", "existing", "current", "future",
    "based", "related", "relevant", "appropriate", "similar", "various", "multiple",
    "several", "primarily", "mainly", "also", "plus", "including", "especially",
}

# Curated skill seeds improve overlap detection beyond generic tokenization.
SKILL_SEEDS: Set[str] = {
    # Programming languages
    "python", "java", "javascript", "typescript", "ruby", "php", "perl", "scala",
    "kotlin", "swift", "dart", "golang", "rust", "csharp", "dotnet", "r", "matlab",
    "lua", "elixir", "clojure", "haskell", "objective", "assembly", "cobol", "fortran",
    "delphi", "vba", "groovy", "julia", "erlang", "fsharp", "solidity",
    # Web frameworks and libraries
    "react", "angular", "vue", "svelte", "nextjs", "nuxt", "node", "nodejs",
    "express", "nestjs", "fastapi", "django", "flask", "spring", "rails", "laravel",
    "symfony", "asp.net", "blazor", "hibernate", "jquery", "redux", "webpack",
    "vite", "babel", "tailwind", "bootstrap", "sass", "html", "css", "graphql",
    "rest", "grpc", "websocket", "json", "xml", "yaml", "openapi", "swagger",
    # Mobile and desktop
    "flutter", "android", "ios", "xamarin", "reactnative", "electron",
    # Data, ML, and AI
    "machine", "learning", "deep", "tensorflow", "pytorch", "keras", "pandas",
    "numpy", "scikit", "scipy", "spark", "hadoop", "kafka", "airflow", "dbt",
    "nlp", "llm", "openai", "langchain", "huggingface", "opencv", "mlops",
    "statistics", "analytics", "data", "science", "etl", "elt", "tableau",
    "power", "bi", "looker", "snowflake", "databricks", "bigquery", "redshift",
    # Databases and storage
    "sql", "postgresql", "mysql", "mariadb", "sqlite", "mongodb", "redis",
    "dynamodb", "cassandra", "elasticsearch", "neo4j", "firebase", "supabase",
    "oracle", "sqlserver", "influxdb", "memcached", "rabbitmq", "celery",
    # Cloud and DevOps
    "aws", "azure", "gcp", "docker", "kubernetes", "terraform", "ansible",
    "jenkins", "gitlab", "github", "git", "ci", "cd", "devops", "helm", "argo",
    "prometheus", "grafana", "datadog", "splunk", "nginx", "apache", "linux",
    "unix", "bash", "powershell", "cloudformation", "lambda", "ec2", "s3", "ecs",
    "eks", "gke", "aks", "vpc", "iam", "circleci", "travis", "sonarqube",
    # Testing and QA
    "testing", "qa", "selenium", "cypress", "playwright", "jest", "pytest",
    "junit", "testng", "mocha", "chai", "vitest", "postman", "insomnia",
    # Security
    "security", "oauth", "jwt", "encryption", "blockchain", "ethereum", "cryptography",
    # Business tools and platforms
    "jira", "confluence", "figma", "photoshop", "salesforce", "sap", "servicenow",
    "excel", "sharepoint", "slack", "notion", "microservices", "api",
    # Methodologies
    "agile", "scrum", "kanban", "devsecops", "tdd", "bdd",
    # Marketing and business skills
    "seo", "sem", "marketing", "sales", "communication", "leadership", "management",
    "collaboration", "teamwork", "mentoring", "negotiation", "presentation",
    "stakeholder", "problem", "solving", "analysis", "research", "planning",
    # Build and package tools
    "npm", "yarn", "pnpm", "maven", "gradle", "pip", "poetry", "conda",
    # ORMs and data access
    "sqlalchemy", "prisma", "typeorm", "sequelize", "hibernate",
}

# Tech marker characters that indicate a token is likely a technology name, not plain English.
TECH_MARKERS = ("+", "#", ".", "-", "/")

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
        # Accept tokens with tech markers such as c++, node.js, c#, ci/cd.
        # Plain English words must not pass through just because they are long enough.
        if re.fullmatch(r"[a-z0-9+#./-]{2,}", cleaned):
            if any(marker in cleaned for marker in TECH_MARKERS):
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
