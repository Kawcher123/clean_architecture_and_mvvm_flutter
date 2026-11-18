# Clean Architecture vs MVVM

This document explains **Clean Architecture** and **MVVM**, their **goals**, **benefits**, and **differences**, using the two Flutter apps in this folder:

| App | Pattern | Path |
|-----|---------|------|
| `clean_auth_app` | Clean Architecture + Provider | [`../clean_auth_app/`](../clean_auth_app/) |
| `mvvm_auth_app` | MVVM + Provider | [`../mvvm_auth_app/`](../mvvm_auth_app/) |

Both apps implement the same features (auth, users, GitHub repos, offline SQLite, secure storage, MethodChannel). Only the **structure of responsibilities** changes.

---

## 1. What problem do architectures solve?

Without a clear architecture, Flutter apps often end up with:

- API calls inside widgets
- Business rules mixed with UI
- Hard-to-test classes
- Painful changes when the backend or database changes

Architecture patterns define **who owns what**, so code stays understandable as the app grows.

---

## 2. Clean Architecture — explained

### Goal

Separate the app into layers so that **business rules stay independent** of UI frameworks, databases, and APIs.

The most important rule:

> **Dependencies point inward.**  
> Outer layers know about inner layers. Inner layers do **not** know about outer layers.

### Layers

```
┌──────────────────────────────────────────┐
│           PRESENTATION LAYER             │
│   Screens • Widgets • Provider           │
│   Goal: show UI and hold UI state        │
└───────────────────┬──────────────────────┘
                    │ calls
                    ▼
┌──────────────────────────────────────────┐
│              DOMAIN LAYER                │
│   Entities • Use Cases • Repository      │
│   interfaces                             │
│   Goal: pure business rules              │
│   (no Flutter, HTTP, SQLite, channels)   │
└───────────────────┬──────────────────────┘
                    │ implemented by
                    ▼
┌──────────────────────────────────────────┐
│               DATA LAYER                 │
│   Models • Repository Impl • DataSources │
│   Goal: talk to API / DB / native code   │
└──────────────────────────────────────────┘
```

### What each piece does

| Piece | Meaning | Example in `clean_auth_app` |
|-------|---------|-----------------------------|
| **Entity** | What something *is* in the business | `User`, `GithubRepo`, `DeviceInfo` |
| **Use Case** | What the app *does* | `Login`, `GetUsers`, `GetDeviceInfo` |
| **Repository interface** | Contract for data needs | `UserRepository` |
| **Repository implementation** | How data is actually fetched/cached | `UserRepositoryImpl` |
| **Model** | External data shape + conversion | `UserModel.fromJson` |
| **Data Source** | One external system | HTTP, SQLite, MethodChannel |
| **Provider** | UI state only | loading / error / list |

### Data flow (Users example)

```
UserScreen
  → UserProvider.fetchUsers()
    → GetUsers (use case)
      → UserRepository (interface)
        → UserRepositoryImpl
          → Remote DataSource (API)
          → Local DataSource (SQLite)
  → notifyListeners()
  → UI updates
```

### Benefits of Clean Architecture

1. **Independent business logic** — Domain does not care if data comes from REST, Firebase, SQLite, or native code.
2. **Easier unit testing** — Mock repository interfaces; test use cases without Flutter UI.
3. **Safer change** — Swap API or database by changing Data layer only.
4. **Clear ownership** — Each class has one job.
5. **Scales with teams** — Multiple developers can work on Presentation / Domain / Data with fewer conflicts.
6. **UI framework freedom** — You could replace Provider with Bloc later; use cases stay.

### Trade-offs

- More files and folders
- More boilerplate (interfaces, use cases, models, entities)
- Can feel heavy for very small apps

### Best when

- Medium to large apps
- Long-term maintenance matters
- Multiple data sources / offline rules
- You want strict testability and team structure

---

## 3. MVVM — explained

### Goal

Separate **UI (View)** from **UI logic and state (ViewModel)**, while **Models/Services** handle data.

MVVM keeps the screen “dumb”: the View displays state; the ViewModel decides what happens when the user taps a button.

### Layers / parts

```
┌──────────────────────────────┐
│            VIEW              │
│  Screens / Widgets           │
│  Goal: render + send events  │
└──────────────┬───────────────┘
               │ binds / reads
               ▼
┌──────────────────────────────┐
│         VIEWMODEL            │
│  ChangeNotifier (Provider)   │
│  Goal: UI state + actions    │
└──────────────┬───────────────┘
               │ calls
               ▼
┌──────────────────────────────┐
│     MODEL / SERVICE          │
│  Models + Services           │
│  Goal: data & external I/O   │
└──────────────────────────────┘
```

### What each piece does

| Piece | Meaning | Example in `mvvm_auth_app` |
|-------|---------|----------------------------|
| **Model** | Data object (often with JSON) | `UserModel`, `GithubRepoModel` |
| **Service** | Fetches/stores data | `AuthService`, `UserService` |
| **ViewModel** | Holds state + calls services | `AuthViewModel`, `UsersViewModel` |
| **View** | UI only | `LoginView`, `UsersView` |

In Flutter with Provider, **`ChangeNotifier` is the ViewModel**.

### Data flow (Users example)

```
UsersView
  → UsersViewModel.fetchUsers()
    → UserService.getUsers()
      → HTTP + SQLite
  → notifyListeners()
  → UI updates
```

Notice: there is **no use case** and **no repository interface**. The ViewModel talks to the Service directly.

### Benefits of MVVM

1. **Simple mental model** — View / ViewModel / Model is easy to teach and apply.
2. **Faster to build** — Fewer layers than Clean Architecture.
3. **UI stays clean** — Widgets do not contain networking or caching logic.
4. **Good testability of ViewModels** — Mock services and test state changes.
5. **Natural fit with Provider** — `ChangeNotifier` maps cleanly to ViewModel.
6. **Enough structure for many apps** — Especially small/medium products.

### Trade-offs

- ViewModels can become large (“God ViewModels”) if business rules grow
- Services are often concrete (harder to swap implementations without more design)
- Business rules may leak into ViewModel or Service
- Less isolation than Clean Architecture for complex domains

### Best when

- Small to medium apps
- Faster delivery is a priority
- One main data source (or simple offline rules)
- Team is smaller / learning architecture

---

## 4. Side-by-side differences

### Structure comparison

| Topic | Clean Architecture | MVVM |
|-------|--------------------|------|
| Main idea | Protect business rules in the center | Separate UI from UI logic |
| Layers | Presentation → Domain → Data | View → ViewModel → Model/Service |
| Business operations | **Use Cases** | Inside ViewModel / Service |
| Data abstraction | **Repository interface** in Domain | Service called directly |
| Business objects | **Entities** (pure) | Often same as Models |
| External conversion | **Models** in Data layer | Models (often shared) |
| State management | Provider in Presentation only | Provider **is** the ViewModel |
| Native MethodChannel | DataSource behind repository | Service called by ViewModel |
| Folder depth | Deeper | Shallower |
| Boilerplate | Higher | Lower |

### Same feature, two wirings

**Login in Clean Architecture**

```
LoginScreen
  → AuthProvider
    → Login use case
      → AuthRepository (abstract)
        → AuthRepositoryImpl
          → AuthRemoteDataSource
          → AuthLocalDataSource (secure storage)
```

**Login in MVVM**

```
LoginView
  → AuthViewModel
    → AuthService
      → HTTP + flutter_secure_storage
```

### Responsibility of Provider

| | Clean Architecture | MVVM |
|--|--------------------|------|
| Provider role | Presentation state holder | The ViewModel itself |
| Should call API? | No | No (Service should) |
| Should contain complex business rules? | No (use cases) | Prefer Service / keep ViewModel focused |
| Calls | Use cases | Services |

### Testing differences

| Test target | Clean Architecture | MVVM |
|-------------|--------------------|------|
| Business rule | Unit-test **use case** with mocked repository | Unit-test ViewModel or Service |
| UI state | Unit-test Provider | Unit-test ViewModel |
| Data conversion | Unit-test Model | Unit-test Model |
| Swap data source | Change repository impl only | Usually change Service (or introduce interface) |

---

## 5. Goals — one-line summary

| Pattern | Primary goal |
|---------|--------------|
| **Clean Architecture** | Keep business rules independent of frameworks and infrastructure |
| **MVVM** | Keep UI independent of state/logic by introducing a ViewModel |

They are not enemies. They answer different questions:

- Clean Architecture asks: *Where do business rules and data contracts live?*
- MVVM asks: *How does the UI talk to logic without becoming messy?*

You can even combine ideas (MVVM-style ViewModels in Presentation, with Clean Architecture Domain/Data underneath). Many production apps do a hybrid.

---

## 6. Which should you choose?

### Prefer Clean Architecture if you need:

- Strict separation for large/long-lived apps
- Multiple data sources and heavy offline logic
- Easy replacement of API / DB / native bridge
- Strong unit testing of business operations
- Clear boundaries for larger teams

→ Use / study: `clean_auth_app`

### Prefer MVVM if you need:

- Faster feature delivery
- Simpler folder structure
- Enough separation for UI vs logic
- A pattern that maps directly to Provider
- Learning architecture without too many layers

→ Use / study: `mvvm_auth_app`

### Practical rule of thumb

| App size / complexity | Suggested starting point |
|-----------------------|--------------------------|
| Prototype / small app | MVVM |
| Growing product with offline + auth + multiple APIs | Clean Architecture (or hybrid) |
| Interview / learning both | Build the same feature both ways (as this repo does) |

---

## 7. Benefits checklist

### Clean Architecture benefits

- [x] Domain independent of Flutter/Provider
- [x] Use cases encapsulate operations (`Login`, `GetUsers`)
- [x] Repository interfaces hide data details
- [x] Easier to change API/DB without touching UI/business
- [x] High unit-test focus on business rules
- [x] Scales better for large teams and complex domains

### MVVM benefits

- [x] Clear View / ViewModel split
- [x] Less boilerplate than full Clean Architecture
- [x] Provider maps naturally to ViewModel
- [x] Faster onboarding for new developers
- [x] Good enough isolation for many real apps
- [x] ViewModels are straightforward to unit-test

---

## 8. How this maps to our projects

### `clean_auth_app` (Clean Architecture)

```
features/users/
├── data/
│   ├── datasources/
│   ├── models/
│   └── repositories/          # implements Domain interface
├── domain/
│   ├── entities/
│   ├── repositories/          # abstract contract
│   └── usecases/
└── presentation/
    ├── providers/
    └── screens/
```

Deep guide: [`../clean_auth_app/docs/ARCHITECTURE.md`](../clean_auth_app/docs/ARCHITECTURE.md)

### `mvvm_auth_app` (MVVM)

```
features/users/
├── models/
├── services/
├── viewmodels/
└── views/
```

Overview: [`../mvvm_auth_app/README.md`](../mvvm_auth_app/README.md)

---

## 9. Common misconceptions

| Myth | Reality |
|------|---------|
| “MVVM and Clean Architecture are mutually exclusive” | You can use MVVM in Presentation and Clean Architecture for Domain/Data. |
| “Provider is an architecture” | Provider is a **state-management** tool. Architecture is how you organize layers. |
| “Clean Architecture means no Provider” | Provider fits Presentation perfectly. |
| “MVVM has no business logic place” | It does — keep heavy rules in Services (or extract Use Cases when they grow). |
| “More layers is always better” | Extra layers without need add cost. Choose based on complexity. |

---

## 10. Learning path in this repo

1. Open **Users** in `mvvm_auth_app` — see View → ViewModel → Service.
2. Open **Users** in `clean_auth_app` — see Provider → Use Case → Repository → DataSources.
3. Compare login flows in both apps.
4. Compare MethodChannel placement:
   - Clean: DataSource behind repository
   - MVVM: Service called by ViewModel
5. Ask for each class: *What is its one responsibility?*

### Remember

> **Clean Architecture** protects the **business core**.  
> **MVVM** protects the **UI** from logic clutter.

Use the one that matches your app’s size and goals — or combine the best of both when the project grows.
