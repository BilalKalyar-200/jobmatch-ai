# JobMatch Web

React + TypeScript frontend for the JobMatch platform. Connects to the FastAPI backend in the sibling `Backend` folder.

## Requirements

- Node.js 20+
- Running JobMatch backend (default `http://127.0.0.1:8000`)

## Setup

```bash
cd Web
npm install
cp .env.example .env
```

Edit `.env`:

```env
VITE_API_BASE_URL=http://127.0.0.1:8000
```

Start the dev server:

```bash
npm run dev
```

The site runs at `http://localhost:5173`.

## Environment variables

| Variable | Description |
|----------|-------------|
| `VITE_API_BASE_URL` | Backend origin without trailing slash |

## Architecture

```
src/
├── api/          # Axios service layer (components never call Axios directly)
├── components/   # Reusable UI and layout
├── hooks/        # React Query hooks wrapping API calls
├── pages/        # Route-level screens
├── store/        # Zustand auth token store
├── types/        # TypeScript interfaces matching backend Pydantic schemas
└── utils/        # Country codes, error helpers
```

## Auth flow

1. Login or signup stores JWT access and refresh tokens in Zustand (persisted).
2. `api/client.ts` attaches the access token to every request.
3. On `401`, the client refreshes tokens once and retries queued requests.
4. Protected routes redirect unauthenticated users to `/login`.

## Pages

- `/login`, `/signup`
- `/preferences` - niche, country (ISO code), multi-city selection
- `/jobs` - live job search results
- `/jobs/:jobId` - job detail, save/unsave, score resume
- `/resume` - upload PDF/DOCX and view match scores
- `/saved` - bookmarked jobs
- `/profile` - edit profile and view search history

## Build

```bash
npm run build
npm run preview
```

## Notes

- Country picker shows full names but always sends ISO 3166-1 alpha-2 codes to the backend.
- Job detail pages use route state and session storage because the backend has no single-job fetch endpoint.
- Resume scoring from job detail navigates to `/resume` with the match result.
