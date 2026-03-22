# Coding Conventions
**Analysis Date: 2026-03-22**

## Backend (Node.js/Express)
- **Module System:** Uses CommonJS (`require`/`module.exports`).
- **Language Level:** ECMAScript 2022.
- **Linting:** ESLint with `eslint:recommended`. Rules allow `console.log` and ignore unused variables starting with `_`.
- **Naming:**
  - Files: `name.controller.js`, `Name.model.js`, `NameService.js`.
  - Variables/Functions: camelCase.
  - Classes: PascalCase.
- **Error Handling:** Uses a centralized `asyncHandler` middleware and `ApiError` utility.
- **Architecture Patterns:** Service-Repository pattern is followed (`src/services/`, `src/repositories/`).
- **Response Pattern:** Standardized using `ApiResponse` utility (`sendSuccess`).

## Frontend (Flutter)
- **Linting:** Uses `package:flutter_lints/flutter.yaml`.
- **State Management:** Riverpod (`flutter_riverpod`).
- **Networking:** Dio (`api_client.dart`).
- **Local Storage:** Hive (`hive_flutter`) and SharedPreferences.
- **Serialization:** Uses `freezed` and `json_serializable`.
- **Project Structure:** Feature-first architecture (`lib/feature/`).
