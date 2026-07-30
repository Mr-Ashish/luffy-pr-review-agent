# High-ROI minimal fixes (triage)

Evidence from live e2e (Odoo monorepo + hub memory):

| Symptom | Observed |
|---------|----------|
| Monorepo checkout | ~3.5 min for full Odoo PR head (`fetch-depth: 0`) |
| Hermes cold install | ~1–2 min every job |
| Actions cache | `cache write denied` despite `actions: write` |
| Hub memory | Written after run, **not loaded into** next review |
| UX | Only 👀 reaction; no done/fail signal |

## Ranked list

| Rank | ID | Fix | Effort | ROI | Status |
|------|-----|-----|--------|-----|--------|
| 1 | **F1** | PR head `fetch-depth: 1` + **sparse-checkout of changed paths only** | S | 🔥 Huge time on monorepos | **Do now** |
| 2 | **F2** | **Cache Hermes install** (`~/.local` + `~/.hermes` bin) | S | 🔥 Cuts cold install | **Do now** |
| 3 | **F3** | **Preload hub `MEMORY.md`** into `HERMES_HOME` before review | S | 🔥 Real memory-backed reviews | **Do now** |
| 4 | **F4** | Drop broken hermes-home Actions cache (hub is SoT) / soft-fail | XS | Removes noise, simpler | **Do now** |
| 5 | **F5** | ✅ / ❌ reactions on trigger comment | XS | Clear UX | **Do now** |
| 6 | **F6** | Cap hub clone depth=1 (already ~20) → 1 | XS | Small | **Do now** |
| 7 | F7 | Pin Hermes version string | S | Repro | Later |
| 8 | F8 | Docker image with Hermes preinstalled | M | Fastest CI | Later |
| 9 | F9 | Inline GitHub review comments | L | Product | Later |
| 10 | F10 | Reusable workflow_call packaging | M | Multi-repo DX | Later |
| 11 | F11 | Author association allowlist | S | Cost control | Later |
| 12 | F12 | Replace previous Luffy comment | S | Less noise | Later |

### Recommendation for this sprint

Implement **F1–F6 only** (minimal code, maximum wall-clock + quality ROI).
