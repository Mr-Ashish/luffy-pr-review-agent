# F28 — Repo-local `.luffy/` memory

- Target repo owns MEMORY + slim runs under `.luffy/`.
- Default `LUFFY_MEMORY_MODE=local`; hub only when `both|hub` or `LUFFY_HUB_PUBLISH=1`.
- Preload: local API contents first, hub fallback if opted in.
- Fat traces stay Actions artifacts.
