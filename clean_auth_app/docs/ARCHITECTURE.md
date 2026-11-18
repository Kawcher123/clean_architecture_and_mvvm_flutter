# Clean Architecture in this project

This document explains how **Clean Architecture + Provider** is applied in
`clean_auth_app`, why each piece exists, and how **MethodChannels** connect
Flutter (Dart) to **Java (Android)** and **Swift (iOS)**.

Compare with MVVM (goals, benefits, differences):  
[`../../docs/CLEAN_ARCHITECTURE_VS_MVVM.md`](../../docs/CLEAN_ARCHITECTURE_VS_MVVM.md)

---

## 1. Big picture

```
┌─────────────────────────────────────────────────────────┐
│                 PRESENTATION LAYER                      │
│   Screens • Widgets • Providers (ChangeNotifier)        │
└──────────────────────────┬──────────────────────────────┘
                           │ calls use cases
                           ▼
┌─────────────────────────────────────────────────────────┐
│                    DOMAIN LAYER                         │
│   Entities • Use Cases • Repository Interfaces          │
│   (pure Dart — no Flutter, HTTP, SQLite, MethodChannel) │
└──────────────────────────┬──────────────────────────────┘
                           │ implemented by
                           ▼
┌─────────────────────────────────────────────────────────┐
│                     DATA LAYER                          │
│   Models • Repository Impl • Data Sources               │
│   (HTTP, Secure Storage, SQLite, MethodChannel)         │
└─────────────────────────────────────────────────────────┘
```

**Golden rule:** dependencies point **inward**.

| Layer        | May depend on                         | Must NOT depend on                          |
|--------------|----------------------------------------|---------------------------------------------|
| Domain       | Nothing external                       | Flutter, Provider, HTTP, SQLite, channels   |
| Data         | Domain                                 | Presentation / Provider                     |
| Presentation | Domain (use cases + entities)          | Data implementations directly               |

---

## 2. Folder map

```
lib/
├── core/                         # Shared infrastructure
│   ├── database/                 # SQLite AppDatabase
│   ├── error/                    # AppException hierarchy
│   ├── network/                  # NetworkInfo, API constants
│   ├── platform/                 # MethodChannel name constants
│   └── usecase/                  # Optional UseCase base type
│
├── features/
│   ├── auth/                     # Login / register / secure tokens
│   ├── users/                    # JSONPlaceholder + SQLite cache
│   ├── github_repos/             # GitHub API + SQLite offline
│   └── native_device/            # Java / Swift MethodChannel demo
│
├── injection_container.dart      # Manual DI (wiring)
└── main.dart                     # MultiProvider + AuthWrapper
```

Each feature repeats the same shape:

```
feature/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/
├── domain/
│   ├── entities/
│   ├── repositories/      # abstract contracts
│   └── usecases/
└── presentation/
    ├── providers/
    └── screens/
```

---

## 3. What each concept is for (and its benefit)

### Entity
Represents a **business object** (`User`, `GithubRepo`, `DeviceInfo`).

**Benefit:** Stable business language. API / DB field names can change; the entity stays the same.

### Use Case
Represents **one application action** (`Login`, `GetUsers`, `GetDeviceInfo`).

**Benefit:** Business rules live outside Provider/UI. Easy to unit-test and reuse if you later swap Provider for Bloc/Riverpod.

### Repository interface (Domain)
Defines **what** data the app needs (`getUsers()`, `getDeviceInfo()`).

**Benefit:** Domain does not care whether data comes from REST, SQLite, or native code.

### Repository implementation (Data)
Coordinates remote + local sources, offline fallback, token persistence.

**Benefit:** One place to change data strategy without touching screens.

### Model
Converts external formats (JSON / Map / SQLite row) ↔ Dart objects; often extends the entity.

**Benefit:** Isolates API/DB shape changes from Domain.

### Data Source
Talks to one external system: HTTP, Secure Storage, SQLite, or MethodChannel.

**Benefit:** Small, focused, mockable classes.

### Provider (Presentation)
Holds UI state (`isLoading`, `error`, lists) and calls use cases, then `notifyListeners()`.

**Benefit:** UI stays dumb; Provider is the only place that manages screen state for that feature.

### Screen / Widget
Renders state from Provider (`Consumer` / `context.watch`).

**Benefit:** Easy widget tests with a fake Provider.

### flutter_secure_storage
Stores auth / GitHub tokens in Keychain (iOS) / Keystore-backed storage (Android).

**Benefit:** Safer than SharedPreferences for secrets.

### SQLite (sqflite)
Caches users and GitHub repos for offline use.

**Benefit:** App remains usable without network after first successful fetch.

### NetworkInfo
Checks connectivity before remote calls.

**Benefit:** Predictable offline behavior instead of cryptic socket errors.

### InjectionContainer
Builds the object graph once (data sources → repos → use cases → providers).

**Benefit:** Screens do not construct infrastructure; testing can inject fakes.

---

## 4. Features in this project

### Auth
- Login / Register / Logout / Forgot password / Session restore
- Optional GitHub PAT login
- Tokens + cached user profile in **secure storage**
- Offline session restore from cached user when network is down

### Users
Classic Clean Architecture sample:
Provider → `GetUsers` → `UserRepository` → remote JSONPlaceholder + SQLite cache

### GitHub Repos
- Authenticated GitHub API (`/user/repos`)
- Offline-first SQLite cache
- Token read from secure storage

### Native Device (MethodChannel learning feature)
- Reads battery / model / OS from **Java** or **Swift**
- Shows native Toast (Android) or UIAlert (iOS)
- Still follows Clean Architecture: native code is just another data source

---

## 5. Data flow examples

### Users (network + cache)

```
UserScreen
  → UserProvider.fetchUsers()
    → GetUsers use case
      → UserRepositoryImpl
          → if online: UserRemoteDataSource (HTTP)
          → cache via UserLocalDataSource (SQLite)
          → if offline: return SQLite cache
    → notifyListeners()
  → ListView updates
```

### Native Device (MethodChannel)

```
NativeDeviceScreen
  → NativeDeviceProvider.loadDeviceInfo()
    → GetDeviceInfo use case
      → NativeDeviceRepositoryImpl
        → NativeDeviceDataSource
          → MethodChannel.invokeMethod('getDeviceInfo')
             ├─ Android: MainActivity.java
             └─ iOS: AppDelegate.swift
    → DeviceInfo entity returned
  → UI displays platform / battery / model
```

Domain still only sees `DeviceInfo`. It never imports `MethodChannel`.

---

## 6. MethodChannels — deep dive

### What is a MethodChannel?
A named two-way bridge between Dart and platform code.

| Side     | Role                                      |
|----------|-------------------------------------------|
| Dart     | `MethodChannel.invokeMethod(name, args)`  |
| Android  | Java/Kotlin `MethodChannel.MethodCallHandler` |
| iOS      | Swift/ObjC `FlutterMethodChannel` handler |

Both sides must use the **same channel name** and **same method names**.

In this project:

| Constant | Value |
|----------|-------|
| Channel  | `com.cleanarchitecture.clean_auth_app/native_device` |
| Methods  | `getDeviceInfo`, `showNativeMessage` |

Defined in:
- Dart: `lib/core/platform/method_channel_constants.dart`
- Java: `MainActivity.java`
- Swift: `AppDelegate.swift`

### Why put MethodChannel in the Data Layer?
Because it is an **external system**, same as HTTP or SQLite.

```
Presentation → Use Case → Repository interface
                              ↑
                     RepositoryImpl
                              ↓
                     NativeDeviceDataSource  ← MethodChannel lives here
                              ↓
                     Java / Swift native APIs
```

**Benefits of this placement:**
1. Domain stays pure Dart (easy unit tests).
2. You can mock the repository without a device.
3. You can later replace MethodChannel with a plugin and Domain stays unchanged.

### Android (Java) — what happens
1. `MainActivity.configureFlutterEngine` registers the channel.
2. On `getDeviceInfo`, Java reads `Build.*` and `BatteryManager`.
3. On `showNativeMessage`, Java shows a `Toast`.
4. Results are sent back with `result.success(...)`.

File: `android/app/src/main/java/com/cleanarchitecture/clean_auth_app/MainActivity.java`

### iOS (Swift) — what happens
1. `didInitializeImplicitFlutterEngine` registers the channel.
2. On `getDeviceInfo`, Swift reads `UIDevice` (battery monitoring enabled).
3. On `showNativeMessage`, Swift presents a `UIAlertController`.
4. Results return via the `result` callback.

File: `ios/Runner/AppDelegate.swift`

### Supported argument / result types
Primitives and collections that both sides understand:
`null`, `bool`, `int`, `double`, `String`, `List`, `Map`.

Complex Dart objects must be converted to `Map` (see `DeviceInfoModel.fromMap`).

### Common mistakes
| Mistake | Symptom |
|---------|---------|
| Channel name mismatch | `MissingPluginException` |
| Method name typo | `notImplemented` / FlutterMethodNotImplemented |
| Calling on web/desktop without handler | MissingPluginException |
| Heavy work on UI thread (native) | Jank / ANR — move to background when needed |
| Domain importing `services.dart` | Breaks Clean Architecture purity |

### When to use MethodChannel vs a plugin
| Use MethodChannel when… | Prefer a pub.dev plugin when… |
|-------------------------|-------------------------------|
| Learning / custom proprietary SDK | Feature already solved (camera, maps) |
| Thin bridge to existing Java/Swift code | You want community maintenance |
| One-off device APIs | Cross-platform coverage matters |

---

## 7. Provider’s role (and what it should NOT do)

Provider **should**:
- Hold UI state
- Call use cases
- Call `notifyListeners()`

Provider **should NOT**:
- Call HTTP / SQLite / MethodChannel directly
- Parse JSON
- Contain complex business rules (put those in use cases)

---

## 8. Testing strategy in this project

| Test type | What it proves | Example in repo |
|-----------|----------------|-----------------|
| **Unit** | Use case / Provider / Model logic in isolation | `test/features/users/...` |
| **Widget** | UI reacts to Provider states | `test/features/users/presentation/user_screen_test.dart` |
| **Integration** | Full app flow with real widget tree | `integration_test/users_flow_test.dart` |

Also included:
- MethodChannel unit test with a mocked binary messenger
  (`test/features/native_device/...`)

### How to run

```bash
# Unit + widget
flutter test

# Integration (needs a device/emulator)
flutter test integration_test/users_flow_test.dart
```

---

## 9. Why Clean Architecture is worth it here

| Without Clean Architecture | With Clean Architecture |
|----------------------------|-------------------------|
| API calls inside widgets | API calls in data sources |
| Business rules in Provider | Business rules in use cases |
| Hard to unit-test | Mock repository / use case easily |
| Native code mixed into UI | Native code behind repository |
| Offline logic scattered | Offline policy in repository impl |

Trade-off: more files. Gain: clearer responsibilities and safer change.

---

## 10. Suggested learning path

1. Read `features/users` (smallest full stack).
2. Trace login in `features/auth`.
3. Open `NativeDeviceScreen` → Dart datasource → Java/Swift handlers.
4. Run `flutter test` and read assertions.
5. Change a native field (e.g. add `brand`) and map it through Model → Entity → UI.

Remember:

> **Entity** = what it **is**  
> **Use Case** = what the app **does**  
> **Model / Data Source** = how data is **fetched and converted**  
> **Provider** = how the UI **state** is held  
> **MethodChannel** = how Flutter **talks to Java/Swift**
