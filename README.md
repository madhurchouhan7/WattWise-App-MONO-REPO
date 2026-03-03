<div align="center">

# ⚡ WattWise

### Smart Energy Management — Track, Analyse, and Save

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter&logoColor=white)](https://flutter.dev)
[![Node.js](https://img.shields.io/badge/Node.js-20.x-339933?logo=nodedotjs&logoColor=white)](https://nodejs.org)
[![Express](https://img.shields.io/badge/Express-5.x-000000?logo=express&logoColor=white)](https://expressjs.com)
[![MongoDB](https://img.shields.io/badge/MongoDB-Atlas-47A248?logo=mongodb&logoColor=white)](https://www.mongodb.com)
[![Firebase](https://img.shields.io/badge/Firebase-Auth-FFCA28?logo=firebase&logoColor=black)](https://firebase.google.com)
[![License](https://img.shields.io/badge/license-ISC-blue)](LICENSE)

---

WattWise is a **cross-platform energy management application** that helps Indian households understand, track, and reduce their electricity consumption. By combining real-time appliance monitoring, personalised energy plans, and intelligent bill analysis, WattWise turns complex power data into clear, actionable insights.

</div>

---

## 📋 Table of Contents

- [Features](#-features)
- [Screenshots](#-screenshots)
- [Architecture](#-architecture)
- [Tech Stack](#-tech-stack)
- [Project Structure](#-project-structure)
- [Getting Started](#-getting-started)
  - [Prerequisites](#prerequisites)
  - [Backend Setup](#backend-setup)
  - [Flutter App Setup](#flutter-app-setup)
- [Environment Variables](#-environment-variables)
- [API Reference](#-api-reference)
- [Onboarding Flow](#-onboarding-flow)
- [Roadmap](#-roadmap)

---

## ✨ Features

### 📱 Flutter App
| Feature | Details |
|---|---|
| **Firebase Auth** | Google Sign-In + Email/Password with automatic token refresh |
| **Smart Onboarding** | 5-step wizard — Location → Household → Appliances → Usage → Dashboard |
| **Live GPS Location** | Auto-detect state & city via device GPS with manual fallback |
| **Appliance Manager** | Add, edit, remove, and tune usage parameters per appliance |
| **Live BBPS Integration** | Securely fetch mock real-time utility bills via Setu BBPS architecture |
| **Insights Dashboard** | Visual energy heatmap trends with category-level drill-downs |
| **Generative AI Plans** | Gemini 2.5 Flash generates custom efficiency targets based on live weather, location, and appliances |
| **Dynamic Dashboard** | 100% interconnected Riverpod UI reflecting live BBPS and Gemini payloads |
| **Profile Management** | Edit household details and preferences at any time |
| **Shimmer Loading** | Skeleton loaders across every async screen — no spinners |
| **Offline-friendly** | Riverpod state persists across widget rebuilds |

### 🖥️ Backend API
| Feature | Details |
|---|---|
| **RESTful API** | Express 5 with versioned routes (`/api/v1`) |
| **Firebase Middleware** | Stateless JWT verification on every protected route |
| **MongoDB Persistence** | Mongoose ODM with timestamps, virtuals and validators |
| **Gemini AI Engine** | Integrates `@google/generative-ai` to natively calculate structured JSON schemas based on user constraints |
| **Setu BBPS Simulator** | Validates consumer IDs and simulates official Bharat Bill Payment System payloads |
| **Rate Limiting** | 200 req / 15 min per IP via `express-rate-limit` |
| **Security** | Helmet headers, CORS whitelist, 10 kb body limit |
| **Health Check** | `GET /health` for uptime monitoring |
| **Structured Errors** | Centralised `ApiError` + `ApiResponse` utilities |

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────────────────┐
│                     Flutter App                          │
│                                                          │
│  ┌──────────┐   ┌───────────┐   ┌────────────────────┐  │
│  │  Screens │──▶│ Providers │──▶│   Repositories     │  │
│  │  & Pages │   │ (Riverpod)│   │ (API + local state)│  │
│  └──────────┘   └───────────┘   └────────┬───────────┘  │
│                                           │ Dio + JWT    │
└───────────────────────────────────────────┼──────────────┘
                                            │
                                            ▼
┌──────────────────────────────────────────────────────────┐
│                   Node.js / Express API                  │
│                                                          │
│  ┌──────────┐   ┌─────────────┐   ┌──────────────────┐  │
│  │  Routes  │──▶│ Controllers │──▶│  Mongoose Models │  │
│  └──────────┘   └─────────────┘   └────────┬─────────┘  │
│         ▲                                   │            │
│  Firebase Admin                             ▼            │
│  (Auth Middleware)                    MongoDB Atlas      │
└──────────────────────────────────────────────────────────┘
```

**State Management:** Riverpod `StateNotifierProvider` + `FutureProvider` throughout.  
**Auth Flow:** Firebase issues the ID token on the client → Flutter sends it in every `Authorization: Bearer <token>` header → Express verifies it server-side with Firebase Admin SDK.

---

## 🛠️ Tech Stack

### Flutter App (`/wattwise_app`)
| Package | Purpose |
|---|---|
| `flutter_riverpod` | Reactive state management |
| `freezed` + `json_serializable` | Immutable model generation |
| `dio` | HTTP client with interceptors |
| `firebase_auth` + `firebase_core` | Authentication |
| `google_sign_in` | Google OAuth |
| `geolocator` + `geocoding` | GPS location & reverse geocoding |
| `flutter_svg` | SVG icon rendering |
| `google_fonts` | Poppins + font system |
| `shimmer` | Skeleton loading effects |
| `confetti` | Onboarding completion celebration |
| `salomon_bottom_bar` | Custom bottom navigation |
| `flutter_animate` | Micro-animations |
| `shared_preferences` + `hive` | Local storage |
| `dots_indicator` | Dot indicator widget |

### Backend (`/backend`)
| Package | Purpose |
|---|---|
| `express` 5 | HTTP framework |
| `mongoose` | MongoDB ODM |
| `@google/generative-ai` | Gemini 2.5 Flash SDK |
| `firebase-admin` | Server-side token verification |
| `helmet` | HTTP security headers |
| `cors` | Cross-origin request handling |
| `express-rate-limit` | Abuse protection |
| `morgan` | Request logging |
| `dotenv` | Environment variable loading |
| `nodemon` | Development hot-reload |

---

## 📁 Project Structure

```
WattWise Mono Repo/
│
├── backend/                        # Node.js REST API
│   ├── config/
│   │   ├── db.js                   # MongoDB connection
│   │   └── firebase.js             # Firebase Admin init
│   └── src/
│       ├── app.js                  # Express entry point
│       ├── controllers/
│       │   ├── auth.controller.js  # Sign-up / sign-in logic
│       │   ├── user.controller.js  # Profile, appliances
│       │   ├── ai.controller.js    # Gemini structured responses
│       │   └── bill.controller.js  # BBPS integration payload
│       ├── middleware/
│       │   ├── auth.middleware.js  # Firebase JWT guard
│       │   └── errorHandler.js     # Global error handler
│       ├── models/
│       │   └── User.model.js       # Mongoose User schema
│       ├── routes/
│       │   ├── index.js
│       │   ├── auth.routes.js
│       │   ├── user.routes.js
│       │   ├── ai.routes.js        # Protected AI pathways
│       │   └── bill.routes.js      # BBPS proxy routes
│       ├── services/
│       │   ├── gemini.service.js   # Prompt engineering core
│       │   └── bbps.service.js     # Mock internal simulator
│       └── utils/
│           ├── ApiError.js
│           └── ApiResponse.js
│
└── wattwise_app/                   # Flutter application
    └── lib/
        ├── core/
        │   ├── network/
        │   │   ├── api_client.dart         # Dio singleton + interceptors
        │   │   ├── api_constants.dart
        │   │   └── api_exception.dart
        │   ├── router/
        │   │   └── app_router.dart         # Auth-aware routing
        │   └── colors.dart
        ├── feature/
        │   ├── auth/                       # Sign in, Sign up, models
        │   ├── on_boarding/                # 5-step onboarding wizard
        │   ├── dashboard/                  # Home energy dashboard
        │   ├── bill/                       # Bill upload & detail
        │   ├── insights/                   # Usage analytics
        │   ├── plans/                      # Energy saving plans
        │   ├── profile/                    # Profile & appliance manager
        │   ├── root/                       # Bottom nav shell
        │   ├── splash_screen/
        │   └── welcome/
        └── utils/
            └── svg_assets.dart
```

---

## 🚀 Getting Started

### Prerequisites

| Tool | Version |
|---|---|
| Flutter SDK | ≥ 3.10 |
| Dart SDK | ≥ 3.0 |
| Node.js | ≥ 20 LTS |
| npm | ≥ 10 |
| MongoDB Atlas | Free tier or higher |
| Firebase project | With Auth + Firestore enabled |

---

### Backend Setup

```bash
# 1. Navigate to backend directory
cd backend

# 2. Install dependencies
npm install

# 3. Create environment file
cp .env.example .env
# Then edit .env with your values (see Environment Variables section)

# 4. Start development server (auto-restarts on changes)
npm run dev

# The API will be available at http://localhost:5000
# Health check: http://localhost:5000/health
```

---

### Flutter App Setup

```bash
# 1. Navigate to the Flutter app directory
cd wattwise_app

# 2. Install Flutter packages
flutter pub get

# 3. Generate Freezed / JSON serializable files
dart run build_runner build --delete-conflicting-outputs

# 4. Set up Firebase
#    a. Create a Firebase project at https://console.firebase.google.com
#    b. Enable Email/Password and Google Sign-In providers
#    c. Download google-services.json → android/app/
#    d. Download GoogleService-Info.plist → ios/Runner/  (for iOS builds)

# 5. Update API base URL in:
#    lib/core/network/api_constants.dart

# 6. Run the app
flutter run
```

> **Note:** The app targets Android API 21+ and iOS 13+.

---

## 🔐 Environment Variables

Create a `.env` file in the `backend/` directory:

```env
# ── Server ─────────────────────────────────
NODE_ENV=development
PORT=5000

# ── MongoDB ────────────────────────────────
MONGODB_URI=mongodb+srv://<user>:<password>@cluster.mongodb.net/wattwise?retryWrites=true&w=majority

# ── Firebase Admin SDK ─────────────────────
# Path to your Firebase service account JSON key
FIREBASE_SERVICE_ACCOUNT_PATH=./config/serviceAccountKey.json

# ── Gemini & Third Party ───────────────────
GEMINI_API_KEY=your_gemini_api_key_here
OPENWEATHER_API_KEY=your_weather_api_key_here

# ── CORS ───────────────────────────────────
# Comma-separated list of allowed origins (leave empty to allow all)
ALLOWED_ORIGINS=
```

> ⚠️ **Never commit `.env` or `serviceAccountKey.json` to version control.**  
> Both are listed in `.gitignore`.

---

## 📡 API Reference

All protected routes require the Firebase ID token in the header:
```
Authorization: Bearer <firebase_id_token>
```

### Auth Routes — `/api/v1/auth`
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/sync` | ✅ | Create or sync user after Firebase login |

### User Routes — `/api/v1/users`
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `GET` | `/me` | ✅ | Fetch current user profile |
| `PATCH` | `/me` | ✅ | Update name, budget, address, household |
| `PUT` | `/me/activplan` | ✅ | Register the Gemini mapped output |

### Integrations — `/api/v1/ai` & `/api/v1/bills`
| Method | Endpoint | Auth | Description |
|--------|----------|------|-------------|
| `POST` | `/ai/generate-plan` | ✅ | Feed context to Gemini for JSON schema return |
| `POST` | `/bills/fetch` | ✅ | Send BillerID + Consumer Number to BBPS simulator |

### Response Format
```json
{
  "success": true,
  "message": "User profile fetched.",
  "data": { ... }
}
```

### Error Format
```json
{
  "success": false,
  "message": "User not found.",
  "statusCode": 404
}
```

---

## 🧭 Onboarding Flow

The app uses a **5-step onboarding wizard** that saves each step to MongoDB incrementally:

```
Step 1 — Welcome
   └─ Introduces WattWise features

Step 2 — Location  (saved to DB)
   ├─ Auto-detect via GPS (lat/lng stored)
   └─ Manual State → City → DISCOM selection

Step 3 — Household  (saved to DB)
   ├─ Number of people
   ├─ Family type (Just Me / Small / Large / Joint)
   └─ House type (Apartment / Bungalow / Independent)

Step 4 — Appliance Selection
   └─ Toggle appliances across 4 categories

Step 5 — Usage Configuration  (saved to DB)
   ├─ Usage level (Low / Medium / High) per appliance
   ├─ Count per appliance
   ├─ Appliance-specific details (star rating, tonnage, etc.)
   └─ Finish → marks onboardingCompleted = true → routes to Dashboard
```

The router watches `sessionOnboardingCompleteProvider` — once `true`, the app navigates to `RootScreen` automatically (reactive routing via Riverpod).

---

## 🗺️ Roadmap

- [x] Integrate AI-powered usage predictions (Gemini 2.5 Flash)
- [x] BBPS Electricity fetch integration
- [ ] Real-time electricity tariff rates by DISCOM
- [ ] Push notification reminders (budget alerts)
- [ ] Multi-home / multi-meter support
- [ ] Bill OCR — auto-extract units from a photo
- [ ] Export reports as PDF
- [ ] Apple Sign-In
- [ ] Dark mode
- [ ] Widget / home-screen energy summary (Android)
- [ ] Unit + integration tests

---

## 📄 License

This project is licensed under the **ISC License** — see the [LICENSE](LICENSE) file for details.

---

<div align="center">

Made with ❤️ by **Madhur** · Saving energy, one household at a time ⚡

</div>
