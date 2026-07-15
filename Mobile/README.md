# JobMatch Mobile

Flutter mobile client for the JobMatch backend. It mirrors the web app flows for auth, preferences, job search, resume scoring, saved jobs, and search history.

## Prerequisites

- Flutter SDK 3.44 or newer
- Running JobMatch backend (default `http://127.0.0.1:8000`)
- Android emulator, iOS simulator, or Windows desktop target

## Backend base URL

The API base URL is configured with a Dart define named `API_BASE_URL`.

Default (Android emulator): `http://10.0.2.2:8000`

Examples:

```bash
# Android emulator
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000

# iOS simulator or local desktop
flutter run --dart-define=API_BASE_URL=http://127.0.0.1:8000

# Physical device on the same Wi-Fi network
flutter run --dart-define=API_BASE_URL=http://192.168.1.10:8000
```

The app calls `{API_BASE_URL}/api/v1`.

## Platform folders

If Android or Windows folders are missing in this project, generate them once without changing `lib/`:

```bash
flutter create . --org com.jobmatch --project-name jobmatch
```

Then re-run the app.

## Install and run

```bash
cd Mobile
flutter pub get
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8000
```

## Features

- JWT auth with secure token storage and automatic refresh on 401
- Light and dark theme toggle, defaults to system theme on first launch
- Preferences with country name display and ISO code submission
- Searchable city picker scoped to selected country
- Job search, detail, save or unsave, and resume scoring
- Resume upload (PDF or DOCX) with readable preview formatting
- Saved jobs and search history with delete support

## Architecture

```
lib/
  config/          API base URL
  core/            ApiClient, theme, storage, utilities, static data
  models/          Backend schema models
  repositories/    Network access layer (screens never call Dio directly)
  providers/       Riverpod state and routing
  screens/         UI screens
  widgets/         Shared UI components
```

## Notes

- Country dropdown shows full names but sends 2-letter ISO codes to the backend.
- Resume preview formatting is display only and is never sent to matching endpoints.
- Access tokens expire in about 30 minutes. Refresh is handled centrally in `ApiClient`.
