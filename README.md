# E-Commerce Customer App

Flutter customer app — catalog, cart, checkout, payments, reviews, notifications, returns.

## Stack

- flutter_bloc, go_router, get_it, dio
- shimmer loading, connectivity_plus (offline banner)
- flutter_secure_storage (JWT)

## Setup

```bash
flutter pub get
cp .env.example .env
flutter run
```

Ensure backend is running at `http://localhost:8080`.

### Android emulator

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

## UX polish

- Empty / error / offline states on home catalog
- Shimmer skeleton while loading products
- Pull-to-refresh on product list
- Branded splash screen (storefront icon + app name)

## CI

GitHub Actions: `.github/workflows/ci.yml` — `flutter pub get && flutter analyze`.

## Build release

APK/IPA builds run outside Docker (local or separate CI job):

```bash
flutter build apk --dart-define=API_BASE_URL=https://api.example.com/api/v1
```
