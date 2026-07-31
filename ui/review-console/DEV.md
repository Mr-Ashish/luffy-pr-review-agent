# DEV — engineering knowledge

> How this part of the system is built.

## Architecture

- The console renders `bundle.signals` in two places: header **chips** (shown only when at least one flag is set) and an **Ops signals (F40)** panel in the Overview tab — so a clean run stays visually quiet and any degraded run is visible without opening a tab.
- Phase tracker state: Phase 2 (standalone review console shell) is **superseded** by the full Run Console; F40 ("ops signals in console", phase 4d) is done, while **4c live progress streaming remains pending** — treat streaming as the next console workstream, not signals.

- Those metrics render in two places: an **Agent loop (F41)** panel in the Overview tab, and measures on the **Loop** tab — i.e. `loop` is a first-class bundle section alongside `signals`, not a sub-field of it.
