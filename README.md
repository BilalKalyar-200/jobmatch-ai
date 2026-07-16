# JobMatch AI

JobMatch AI helps job hunters find real, live job postings filtered by
niche, country, and multiple cities, and scores their resume against a
specific job description using AI powered keyword extraction and
semantic similarity. It matches candidates with jobs from LinkedIn,
Indeed, Glassdoor, and other platforms in one place, and highlights
exactly which skills match and which are missing.

## Project structure

This repository is a monorepo containing three independent projects
that share one backend:
jobmatch-ai/
backend/   FastAPI backend, shared by both the mobile app and the website
mobile/    Flutter mobile app
web/       React website

All three parts talk to the same backend over REST endpoints, so business
logic, AI scoring, and job search live in one place.

## Tech stack

- Backend: Python, FastAPI, PostgreSQL, SQLAlchemy, Alembic, JWT auth
- Mobile: Flutter, Riverpod, go_router, Dio
- Web: React, TypeScript, Tailwind CSS
- AI matching: sentence-transformers for semantic similarity, curated
  skill and phrase extraction for keyword matching
- Job data: JSearch API via RapidAPI

## Getting started

Clone the repository first:

```bash
git clone https://github.com/BilalKalyar-200/jobmatch-ai.git
cd jobmatch-ai
```

You will need a running backend before either frontend is useful, so set
that up first.

### 1. Backend setup

```bash
cd backend
python -m venv .venv
```

Activate the virtual environment:

Windows:
```bash
.venv\Scripts\activate
```

macOS or Linux:
```bash
source .venv/bin/activate
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Copy the example environment file and fill in your own values:

```bash
cp .env.example .env
```

You will need:
- A PostgreSQL database connection string. This project was built and
  tested using a free Neon (neon.tech) database, but any PostgreSQL
  instance works.
- A JSearch API key from RapidAPI (rapidapi.com, search for JSearch,
  subscribe to the free tier, copy the key from the Endpoints tab).
- A JWT secret key, any random string of at least 32 characters.

Run database migrations:

```bash
alembic upgrade head
```

Start the backend:

```bash
uvicorn app.main:app --host 0.0.0.0 --port 8000 --reload
```

The API will be available at `http://localhost:8000`, with interactive
documentation at `http://localhost:8000/docs`.

### 2. Mobile app setup (Flutter)

```bash
cd mobile
flutter pub get
```

Run the app, pointing it at your backend. The correct base URL depends
on where you are running it:

| Target | API_BASE_URL |
|---|---|
| Android emulator | `http://10.0.2.2:8000` |
| iOS simulator or desktop | `http://127.0.0.1:8000` |
| Physical device | your computer's LAN IP, for example `http://192.168.1.10:8000` |
| Chrome (web debug) | `http://localhost:8000` |

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

### 3. Web app setup (React)

```bash
cd web
npm install
```

Copy the example environment file and fill in your own VITE_API_BASE_URL:

```bash
cp .env.example .env
```

Start the development server:

```bash
npm run dev
```

## Core features

- Email and password authentication with JWT access and refresh tokens
- Search live job postings by niche, country, and multiple cities at
  once
- Upload a resume as PDF or DOCX, automatically parsed into text
- Score a resume against any job description, with a keyword match
  score, a semantic similarity score, and clear lists of matched and
  missing skills
- Save jobs for later and review search history, with the ability to
  delete saved jobs or history entries
- Light and dark theme support across both frontends

## Deployment

The backend is deployed separately from both frontends since it is the
shared foundation both apps depend on. When deploying:

- Set `DEBUG=false` in production.
- Set `ALLOWED_ORIGINS` to the real deployed URLs of your web and any
  other frontend, comma separated.
- Run `alembic upgrade head` on every deploy to keep the database
  schema current.
- Never commit `.env` files, they are already excluded via
  `.gitignore`.

## Security notes

This backend includes rate limiting on authentication endpoints, JWT
refresh token rotation, file upload size limits, and input length
validation throughout. See `backend/README.md` for further backend
specific setup and security details.

## License

This project is currently unlicensed and intended for personal and
educational use.
