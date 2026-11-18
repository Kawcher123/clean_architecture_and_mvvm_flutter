# Clean Architecture + Provider (Flutter)

Flutter app demonstrating **Clean Architecture** with **Provider**, including:

- Authentication (login / register / logout / forgot password / session restore)
- Secure token storage via `flutter_secure_storage`
- Users feature (JSONPlaceholder) with SQLite offline cache
- GitHub repositories with secure PAT + SQLite offline-first cache
- Native Device feature via **MethodChannel** (Java Android + Swift iOS)

## Architecture

Full guide: **[docs/ARCHITECTURE.md](docs/ARCHITECTURE.md)** (layers, benefits, MethodChannels, testing).

```
Presentation  →  Domain  ←  Data
(Provider/UI)    (Entities, Use Cases, Repository interfaces)
                 (Models, DataSources, Repository implementations)
```

Dependencies point **inward**. Domain has no Flutter / HTTP / SQLite / MethodChannel imports.

## Run

```bash
cd clean_architecture/clean_auth_app
flutter pub get
flutter run   # use Android/iOS for Native Device MethodChannel
```

### Native Device (MethodChannel)

After login, open **Native Device** on Home. It calls:

| Platform | File | Native UI |
|----------|------|-----------|
| Android  | `android/.../MainActivity.java` | Toast |
| iOS      | `ios/Runner/AppDelegate.swift` | UIAlert |

### Tests

```bash
flutter test                                              # unit + widget
flutter test integration_test/users_flow_test.dart -d macos
```

### Demo credentials (reqres.in)

| Action   | Email               | Password    |
|----------|---------------------|-------------|
| Login    | eve.holt@reqres.in  | cityslicka  |
| Register | eve.holt@reqres.in  | pistol      |

### GitHub repos (recommended for offline demo)

1. Create a [GitHub Personal Access Token](https://github.com/settings/tokens) (classic) with `repo` scope.
2. On the login screen, tap **Login with GitHub token**.
3. Paste the token (stored in the platform keychain / Keystore).
4. Open **GitHub Repositories** — data is cached in SQLite and available offline.

## Folder structure

```
lib/
├── core/
│   ├── database/          # SQLite AppDatabase
│   ├── error/             # App exceptions
│   ├── network/           # NetworkInfo + API constants
│   └── usecase/
├── features/
│   ├── auth/
│   ├── users/
│   └── github_repos/
├── injection_container.dart
└── main.dart
```

## Security notes

- Auth / GitHub tokens use **flutter_secure_storage** (not SharedPreferences).
- Never commit personal access tokens.
- For production: add refresh tokens, certificate pinning, and server-side logout.
