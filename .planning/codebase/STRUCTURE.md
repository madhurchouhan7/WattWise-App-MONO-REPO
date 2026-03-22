# Codebase Structure

**Analysis Date:** 2025-05-14

## Directory Layout

```
WattWise Mono Repo/
├── backend/            # Express.js API
│   ├── config/         # Database and Firebase configurations
│   ├── scripts/        # Data migration and utility scripts
│   ├── src/            # Application source code
│   │   ├── agents/     # AI workflow nodes (Analyst, Strategist, etc.)
│   │   ├── controllers/# Request handlers
│   │   ├── middleware/ # Security, logging, and auth middleware
│   │   ├── models/     # Mongoose schemas
│   │   ├── repositories/# Data access layer
│   │   ├── routes/     # Route definitions
│   │   ├── services/   # Business logic
│   │   ├── utils/      # Common utilities (ApiResponse, ApiError)
│   │   └── app.js      # App entry point
│   └── tests/          # Integration and unit tests
├── wattwise_app/       # Flutter Mobile Application
│   ├── lib/            # Source code
│   │   ├── core/       # Shared utilities, networking, and theme
│   │   ├── feature/    # Feature-based domain modules
│   │   │   ├── auth/   # Auth flow
│   │   │   ├── bill/   # Bill management and OCR
│   │   │   ├── dashboard/ # User overview
│   │   │   ├── insights/# Energy usage analysis
│   │   │   └── plans/  # AI-driven efficiency plans
│   │   └── main.dart   # App entry point
│   ├── assets/         # Images, fonts, and SVG icons
│   └── test/           # Flutter widget and unit tests
└── .planning/          # GSD project planning and codebase docs
```

## Directory Purposes

**backend/src/agents:**
- Purpose: Contains the "brains" of the application, utilizing Gemini AI for specific tasks.
- Contains: Analysts, Strategists, and Copywriters for plan generation.
- Key files: `backend/src/agents/efficiency_plan/index.js`

**backend/src/controllers:**
- Purpose: Maps HTTP endpoints to service methods.
- Contains: JavaScript files for each resource (User, Bill, Appliance, etc.).
- Key files: `backend/src/controllers/user.controller.js`

**wattwise_app/lib/core:**
- Purpose: The foundation of the Flutter app, shared across all features.
- Contains: Networking (`api_client.dart`), routing (`app_router.dart`), and base theme (`app_theme.dart`).
- Key files: `wattwise_app/lib/core/network/api_client.dart`

**wattwise_app/lib/feature:**
- Purpose: Modularizes the app by business domain.
- Contains: Subfolders for each feature, each having `providers`, `screens`, `widgets`, and `services`.
- Key files: `wattwise_app/lib/feature/bill/screen/add_bill_screen.dart`

## Key File Locations

**Entry Points:**
- `backend/src/app.js`: Express application initialization.
- `wattwise_app/lib/main.dart`: Flutter application entry point.

**Configuration:**
- `backend/config/db.js`: MongoDB connection setup.
- `backend/config/firebase.js`: Firebase Admin initialization.
- `wattwise_app/lib/firebase_options.dart`: Flutter Firebase project configuration.

**Core Logic:**
- `backend/src/services/UserService.js`: Main user business logic.
- `backend/src/agents/efficiency_plan/index.js`: Main AI plan generation logic.

**Testing:**
- `backend/tests/`: Backend test suites.
- `wattwise_app/test/`: Flutter test files.

## Naming Conventions

**Files:**
- Backend: `.controller.js`, `.service.js`, `.model.js`, `.routes.js` (camelCase prefix)
- Frontend: `.dart` (snake_case), `_screen.dart`, `_provider.dart`, `_widget.dart`

**Directories:**
- Backend: `snake_case` (e.g., `middleware`, `repositories`)
- Frontend: `snake_case` (e.g., `core`, `feature`)

## Where to Add New Code

**New Feature (Full Stack):**
1. Backend: Create `models/[Resource].model.js`, `repositories/[Resource]Repository.js`, `services/[Resource]Service.js`, `controllers/[Resource].controller.js`, and `routes/[Resource].routes.js`.
2. Frontend: Create `lib/feature/[resource]/` folder with `models`, `providers`, `screen`, and `widgets` subdirectories.

**New API Endpoint:**
1. Define in `backend/src/routes/[feature].routes.js`.
2. Implement logic in `backend/src/controllers/[feature].controller.js`.
3. Add business logic to `backend/src/services/[Feature]Service.js`.

**New Shared Component (Frontend):**
1. Implementation: `wattwise_app/lib/core/widgets/`.

## Special Directories

**.planning/codebase:**
- Purpose: Contains codebase analysis and documentation for AI agents.
- Generated: Yes (by `/gsd:map-codebase`).
- Committed: Yes.

---

*Structure analysis: 2025-05-14*
