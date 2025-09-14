# mini_business_directory

A new Flutter project.

## Getting Started

This project is a starting point for a Flutter application.

A few resources to get you started if this is your first Flutter project:

- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)
- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

For help getting started with Flutter development, view the
[online documentation](https://docs.flutter.dev/), which offers tutorials,
samples, guidance on mobile development, and a full API reference.

# TECH_NOTES

## Architecture
- Small MVVM-ish approach:
  - Models: `lib/models/` (Business domain model and validation)
  - Services: `lib/services/` (ApiService using Dio, StorageService for SharedPreferences)
  - State: `lib/providers/` (Provider + ChangeNotifier)
  - UI: `lib/screens/`, `lib/widgets/`

## Key decisions / trade-offs
- **Dio interceptor for local data**: Using a Dio interceptor to return bundled JSON keeps a single networking abstraction while fulfilling the "use Dio" requirement without an external server.
- **SharedPreferences for cache**: Chosen because data is small and simple. For larger or structured caches, use Hive or sqflite.
- **Provider (ChangeNotifier)**: Simple and quick for a small app; easy to extend. For more complex state with many flows, consider Riverpod or BLoC.
- **Validation**: `Business.fromMap` normalizes key names and performs basic phone & required-field validation. Failure throws `FormatException`.

## Where I'd improve with more time
- Add proper dependency injection (GetIt) to make services mockable in tests.
- Add unit tests for provider, model validation, and ApiService's interceptor behavior.
- Replace SharedPreferences with Hive or SQLite for more robust storage and queries.
- Add search state in provider so filtering can be done centrally (currently done locally in the list screen).
- Add pagination and more robust error classification, retries, exponential backoff for real API usage.

## How the offline flow works
1. App requests businesses via `BusinessProvider.load()`
2. `ApiService` (Dio) returns data from local asset JSON
3. Provider parses, validates, and saves stringified JSON in `SharedPreferences`
4. On subsequent runs, if API fails, provider attempts to load cached JSON for offline display

