## 2026-09-22 - [Direct Riverpod State Updates in Search Fields]
**Learning:** In Riverpod/Drift setups, binding a TextField's `onChanged` directly to a StateNotifier that immediately invalidates a FutureProvider (which runs a DB query) causes severe performance degradation as every single keystroke triggers a full DB read cycle and UI re-render.
**Action:** Always implement a debouncer (e.g., using `Timer` in `dart:async`) inside the Notifier for search/filter inputs before updating the state to avoid flooding the local SQLite DB with intermediate queries.
