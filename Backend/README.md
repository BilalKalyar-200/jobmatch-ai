# JobMatch Backend

Production-ready FastAPI backend for the JobMatch platform. This API is frontend agnostic and serves both the Flutter mobile app and React website with clean JSON responses.

## Features

- Email and password auth with bcrypt hashing and JWT access/refresh tokens
- User profiles with niche, country, and city preferences
- Live job search via JSearch (RapidAPI), with per-city queries, merge, dedupe, and short TTL cache
- Resume upload (PDF, DOCX) with text extraction and database storage
- Resume to job match scoring using keyword overlap and local sentence embeddings
- Saved jobs and search history for authenticated users
- OpenAPI docs at `/docs`

## Requirements

- Python 3.11
- PostgreSQL 14+
- RapidAPI key with JSearch access

## Project structure

```
Backend/
├── app/
│   ├── core/           # Security, cache, matching algorithms
│   ├── models/         # SQLAlchemy ORM models
│   ├── repositories/   # Database access layer
│   ├── routers/        # Thin HTTP route handlers
│   ├── schemas/        # Pydantic v2 request/response models
│   ├── services/       # Business logic
│   ├── config.py
│   ├── database.py
│   ├── dependencies.py
│   └── main.py
├── alembic/            # Database migrations
├── requirements.txt
├── .env.example
└── README.md
```

## Local setup

### 1. Create a virtual environment

```bash
cd Backend
python -m venv .venv
```

Windows PowerShell:

```powershell
.\.venv\Scripts\Activate.ps1
```

macOS/Linux:

```bash
source .venv/bin/activate
```

### 2. Install dependencies

```bash
pip install -r requirements.txt
```

The first match request downloads the `all-MiniLM-L6-v2` embedding model locally.

### 3. Configure environment variables

```bash
cp .env.example .env
```

Edit `.env` and set at minimum:

- `DATABASE_URL`
- `JWT_SECRET_KEY` (at least 32 characters)
- `RAPIDAPI_KEY`

### 4. Create the database

Create an empty PostgreSQL database, for example:

```sql
CREATE DATABASE jobmatch;
CREATE USER jobmatch WITH PASSWORD 'jobmatch';
GRANT ALL PRIVILEGES ON DATABASE jobmatch TO jobmatch;
```

Update `DATABASE_URL` to match your credentials.

### 5. Run migrations

```bash
alembic upgrade head
```

### 6. Start the server

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

- API base: `http://127.0.0.1:8000/api/v1`
- Swagger UI: `http://127.0.0.1:8000/docs`
- Health check: `http://127.0.0.1:8000/health`

Use `0.0.0.0` so the service is reachable from emulators and LAN devices during mobile development.

## Environment variables

See `.env.example` for the full list. Secrets are never hardcoded in source code.

| Variable                | Purpose                                        |
| ----------------------- | ---------------------------------------------- |
| `DATABASE_URL`          | PostgreSQL SQLAlchemy URL                      |
| `JWT_SECRET_KEY`        | Signs access and refresh tokens                |
| `RAPIDAPI_KEY`          | JSearch API key from RapidAPI                  |
| `ALLOWED_ORIGINS`       | Comma-separated CORS origins                   |
| `KEYWORD_SCORE_WEIGHT`  | Weight for keyword overlap in match score      |
| `SEMANTIC_SCORE_WEIGHT` | Weight for embedding similarity in match score |

## API overview

All protected routes require `Authorization: Bearer <access_token>`.

### Auth

| Method | Path                   | Description                 |
| ------ | ---------------------- | --------------------------- |
| POST   | `/api/v1/auth/signup`  | Register and receive tokens |
| POST   | `/api/v1/auth/login`   | Login and receive tokens    |
| POST   | `/api/v1/auth/refresh` | Refresh token pair          |
| POST   | `/api/v1/auth/logout`  | Revoke refresh token        |

### Users

| Method | Path               | Description    |
| ------ | ------------------ | -------------- |
| GET    | `/api/v1/users/me` | Get profile    |
| PATCH  | `/api/v1/users/me` | Update profile |

### Jobs

| Method | Path                  | Description                |
| ------ | --------------------- | -------------------------- |
| POST   | `/api/v1/jobs/search` | Search live postings       |
| POST   | `/api/v1/jobs/match`  | Score resume against a job |

### Resumes

| Method | Path                     | Description                |
| ------ | ------------------------ | -------------------------- |
| POST   | `/api/v1/resumes/upload` | Upload PDF or DOCX resume  |
| GET    | `/api/v1/resumes/me`     | Get latest resume metadata |

### Saved jobs and history

| Method | Path                          | Description         |
| ------ | ----------------------------- | ------------------- |
| POST   | `/api/v1/saved/jobs`          | Save a job          |
| DELETE | `/api/v1/saved/jobs/{job_id}` | Unsave a job        |
| GET    | `/api/v1/saved/jobs`          | List saved jobs     |
| GET    | `/api/v1/saved/searches`      | List search history |

## Match scoring formula

The scoring logic lives in `app/core/matching/scorer.py`, separate from routes.

```
final_score = (keyword_weight * keyword_score) + (semantic_weight * semantic_score)
```

Defaults:

- `keyword_weight = 0.4`
- `semantic_weight = 0.6`

Keyword score is the percentage of extracted job keywords found in the resume. Semantic score is cosine similarity between sentence embeddings of the full resume and job description, mapped to 0-100.

## Production deployment

This project runs locally with `uvicorn app.main:app --reload` for development.
For production, follow these practices:

- Never use `--reload` in production, it is a development-only convenience
  that adds overhead and is not intended for live traffic.
- Run with multiple worker processes, for example:
  `uvicorn app.main:app --host 0.0.0.0 --port 8000 --workers 4`
- Put a reverse proxy such as nginx in front of uvicorn to terminate TLS
  and forward requests, do not expose uvicorn directly to the internet.
- Ensure `DEBUG=false` (the default) in any environment reachable from
  the internet, so raw exception details are never returned to clients.
- `/docs`, `/redoc`, and `/openapi.json` are public by default. If you do
  not want your API schema publicly browsable in production, set
  `docs_url=None, redoc_url=None, openapi_url=None` in the `FastAPI(...)`
  constructor in `app/main.py`, or gate them behind authentication.
- Confirm `.env` is listed in `.gitignore` and was never committed to
  version control. Rotate `JWT_SECRET_KEY` if you suspect it was ever
  exposed.

## Deployment notes

This project is structured for platforms such as Render or Railway:

1. Set all environment variables from `.env.example` in the platform dashboard.
2. Use the platform-provided `DATABASE_URL`.
3. Run `alembic upgrade head` as a release or start command step.
4. Start with `uvicorn app.main:app --host 0.0.0.0 --port $PORT`.

No application code hardcodes `localhost`. CORS origins are configured through `ALLOWED_ORIGINS`.

## Error responses

Errors return JSON, never HTML:

```json
{
  "error": "Human-readable message",
  "details": {}
}
```

Common status codes: `401` unauthorized, `404` not found, `409` conflict, `422` validation, `502` upstream API failure.
