# Testing Strategy
**Analysis Date: 2026-03-22**

## Backend (Node.js/Express)
- **Framework:** Jest.
- **Location:** `backend/tests/`.
- **Naming:** `*.test.js`.
- **Current State:** Basic sanity checks (e.g., `sanity.test.js`). Pipeline configured to run `jest --forceExit`.

## Frontend (Flutter)
- **Framework:** `flutter_test`.
- **Location:** `wattwise_app/test/`.
- **Naming:** `*_test.dart`.
- **Current State:** Basic sanity check in `widget_test.dart` to bypass CI requirements until mocking is established.
