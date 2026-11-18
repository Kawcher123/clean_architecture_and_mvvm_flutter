# Clean Architecture vs MVVM (Flutter + Provider)

Two sister apps with the **same features**, different architecture styles.

| Project | Pattern | Path |
|---------|---------|------|
| Clean Architecture | Presentation / Domain / Data + Provider | [`clean_auth_app/`](clean_auth_app/) |
| MVVM | View / ViewModel / Model + Services + Provider | [`mvvm_auth_app/`](mvvm_auth_app/) |

## Read this first

**Full comparison (goals, benefits, differences):**  
[`docs/CLEAN_ARCHITECTURE_VS_MVVM.md`](docs/CLEAN_ARCHITECTURE_VS_MVVM.md)

Shared feature set:

- Auth + secure token storage
- Users API + SQLite offline
- GitHub repos + SQLite offline
- Native MethodChannel (Java + Swift)

More docs:

- Clean Architecture deep dive: [`clean_auth_app/docs/ARCHITECTURE.md`](clean_auth_app/docs/ARCHITECTURE.md)
- MVVM project overview: [`mvvm_auth_app/README.md`](mvvm_auth_app/README.md)
