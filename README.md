# E-Commerce Customer App

Flutter app — Phase 1 Auth shell.

## Stack

- flutter_bloc, go_router, get_it, dio
- flutter_secure_storage (access + refresh token)

## Run

```bash
flutter pub get
flutter run
```

Ensure backend is running at `http://localhost:8080`.

For Android emulator use:

```bash
flutter run --dart-define=API_BASE_URL=http://10.0.2.2:8080/api/v1
```

## Screens (Phase 1)

- Splash → Onboarding (3 slides) → Login / Register
- Home placeholder, Profile skeleton with logout
