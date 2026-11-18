# MVVM + Provider (Flutter)

Sister app to `clean_auth_app`, same features, different architecture.

```
clean_architecture/
├── clean_auth_app/   ← Clean Architecture + Provider
└── mvvm_auth_app/    ← MVVM + Provider  (this project)
```

## MVVM structure

```
lib/features/<feature>/
├── models/        # Data objects (+ JSON/Map conversion)
├── services/      # API, SQLite, secure storage, MethodChannel
├── viewmodels/    # ChangeNotifier — UI state + calls services
└── views/         # Screens / widgets
```

**Flow**

```
View  →  ViewModel  →  Service  →  API / SQLite / Native
  ↑           │
  └─ notifyListeners()
```

## Features (same as Clean Architecture app)

- Auth (login / register / logout / forgot password / GitHub PAT)
- Secure token storage (`flutter_secure_storage`)
- Users (JSONPlaceholder) + SQLite offline cache
- GitHub repos + SQLite offline cache
- Native Device MethodChannel (Java + Swift)

## Run

```bash
cd clean_architecture/mvvm_auth_app
flutter pub get
flutter run   # Android/iOS for MethodChannel
```

Demo login: `eve.holt@reqres.in` / `cityslicka`

## MVVM vs Clean Architecture

Full comparison (goals, benefits, differences):  
[`../docs/CLEAN_ARCHITECTURE_VS_MVVM.md`](../docs/CLEAN_ARCHITECTURE_VS_MVVM.md)

| | MVVM (this app) | Clean Architecture (`clean_auth_app`) |
|--|-----------------|----------------------------------------|
| Layers | View → ViewModel → Service → Model | Presentation → Domain → Data |
| Business ops | Inside ViewModel / Service | Dedicated **Use Cases** |
| Data contract | Service called directly | **Repository interface** in Domain |
| Entities | Often same as models | Separate Domain entities |
| Native code | Inside Service | Inside DataSource behind repository |
| Best for | Medium apps, faster delivery | Larger apps, strict testability, team scale |

In MVVM, Provider’s `ChangeNotifier` **is** the ViewModel.  
In Clean Architecture, Provider is only the Presentation state holder and should call use cases—not services/APIs directly.

## MethodChannel

| Platform | File |
|----------|------|
| Android | `android/.../MainActivity.java` |
| iOS | `ios/Runner/AppDelegate.swift` |

Channel: `com.mvvmauth.mvvm_auth_app/native_device`
