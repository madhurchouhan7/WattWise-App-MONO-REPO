# External Integrations
**Analysis Date: 2026-03-22**

## APIs & External Services
**AI Services:**
- Google Generative AI (Gemini) - Used for efficiency plans (`backend/src/controllers/ai.controller.js`)
- OpenAI - Supported via LangChain

**Utilities/Payments:**
- BBPS (Bharat Bill Payment System) - Bill fetching and payments (`backend/src/controllers/bbps.controller.js`)

## Data Storage
**Databases:**
- MongoDB - Primary database via Mongoose (`backend/config/db.js`)
- Redis - Caching via `ioredis` (`backend/package.json`)

**Local Storage:**
- Hive & Shared Preferences - App local persistence (`wattwise_app/pubspec.yaml`)

## Authentication & Identity
**Auth Provider:**
- Firebase Authentication - Managed via `firebase_auth` (client) and `firebase-admin` (server-side verification)

## Monitoring & Observability
**Logs:**
- Morgan - HTTP request logging
- Custom logging middleware in `backend/src/middleware/logging.middleware.js`
