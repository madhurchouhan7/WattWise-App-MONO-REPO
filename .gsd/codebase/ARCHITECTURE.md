# Architecture

**Analysis Date:** 2025-05-14

## Pattern Overview

**Overall:** Monorepo with a Node.js Express Backend and a Flutter Mobile App.

**Key Characteristics:**
- **Modular Monorepo:** Separate directories for `backend` and `wattwise_app` with shared logic defined via API contracts.
- **Layered Backend Architecture:** Follows a Controller-Service-Repository pattern for clear separation of concerns.
- **Feature-First Frontend:** Flutter app organized by domain features (Auth, Bill, Insights, etc.) using Riverpod for state management.

## Layers

**API Layer (Backend):**
- Purpose: Handles incoming HTTP requests and response formatting.
- Location: `backend/src/controllers`
- Contains: Express request handlers, validation calls, and response sending.
- Depends on: `backend/src/services`, `backend/src/utils/ApiResponse.js`
- Used by: External clients (Flutter app).

**Service Layer (Backend):**
- Purpose: Contains core business logic and orchestrates data operations.
- Location: `backend/src/services`
- Contains: Business rules, AI integration logic, and service classes (e.g., `UserService`, `ApplianceService`).
- Depends on: `backend/src/repositories`, `backend/src/models`
- Used by: `backend/src/controllers`

**Data Access Layer (Backend):**
- Purpose: Abstracts database operations (Mongoose).
- Location: `backend/src/repositories`
- Contains: CRUD operations and complex queries.
- Depends on: `backend/src/models`
- Used by: `backend/src/services`

**AI Agents Layer (Backend):**
- Purpose: Specialized logic for AI-driven insights and plan generation.
- Location: `backend/src/agents`
- Contains: Analyst, strategist, and copywriter nodes for complex AI flows.
- Depends on: `backend/src/services/gemini.service.js`
- Used by: `backend/src/controllers/ai.controller.js`

**Feature Layer (Frontend):**
- Purpose: UI and state management for specific app domains.
- Location: `wattwise_app/lib/feature`
- Contains: `screens`, `widgets`, `providers`, `models`, and `services`.
- Depends on: `wattwise_app/lib/core`
- Used by: `wattwise_app/lib/main.dart`, `wattwise_app/lib/core/router/app_router.dart`

**Core Layer (Frontend):**
- Purpose: Shared utilities, networking, and common widgets.
- Location: `wattwise_app/lib/core`
- Contains: `network/api_client.dart`, `router/app_router.dart`, `app_theme.dart`
- Depends on: External packages (Dio, Riverpod, etc.)
- Used by: All features in `wattwise_app/lib/feature`

## Data Flow

**Bill Processing Flow:**

1. User uploads a bill image via `wattwise_app/lib/feature/bill/screen/add_bill_screen.dart`.
2. App sends image to `backend/src/controllers/bill.controller.js`.
3. Controller invokes `BillService` to process the bill.
4. AI Agent (`backend/src/agents/bill_decoder`) parses the bill data.
5. Results are saved via `BillRepository` and returned to the app.

**State Management (Frontend):**
- Handled by **Riverpod**. Providers in `lib/feature/*/providers/` manage local and remote state.
- Local persistence uses **Hive** for high-frequency data (streaks, heatmap) and **SharedPreferences** for simple flags.

## Key Abstractions

**BaseRepository:**
- Purpose: Provides common CRUD methods for all database repositories.
- Examples: `backend/src/repositories/BaseRepository.js`
- Pattern: Repository Pattern.

**BaseService:**
- Purpose: Common business logic methods like logging and document transformation.
- Examples: `backend/src/services/BaseService.js`
- Pattern: Service Pattern.

**ConsumerWidget:**
- Purpose: Flutter widgets that react to Riverpod state changes.
- Examples: `wattwise_app/lib/core/router/app_router.dart`, `wattwise_app/lib/feature/dashboard/screens/dashboard_screen.dart`
- Pattern: Observer Pattern (via Riverpod).

## Entry Points

**Backend Server:**
- Location: `backend/src/app.js`
- Triggers: HTTP requests via `npm start`.
- Responsibilities: Middleware setup (CORS, Helmet, Rate limiting), route mounting, DB/Firebase connection.

**Flutter App:**
- Location: `wattwise_app/lib/main.dart`
- Triggers: App launch.
- Responsibilities: Firebase initialization, API client setup, Local DB (Hive) initialization, and mounting `ProviderScope`.

## Error Handling

**Strategy:** Centralized error handling with custom error classes and middleware.

**Patterns:**
- **Backend:** `ApiError` class and `errorHandler` middleware in `backend/src/middleware/errorHandler.js`.
- **Frontend:** `ApiException` class in `wattwise_app/lib/core/network/api_exception.dart` and `AsyncValue.error` handling in Riverpod providers.

## Cross-Cutting Concerns

**Logging:** Multi-level logging in Backend via `backend/src/middleware/logging.middleware.js` (request, activity, performance, security).
**Validation:** Joi-based validation in Backend using `backend/src/middleware/validation.middleware.js`.
**Authentication:** Firebase Auth based. Verified via `backend/src/middleware/authMiddleware.js` on backend and `authStateProvider` on frontend.

---

*Architecture analysis: 2025-05-14*
