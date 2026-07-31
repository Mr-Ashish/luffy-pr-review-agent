# Luffy Review Console (OpenUI)

Interactive viewer for Luffy PR reviews using [OpenUI](https://github.com/thesysdev/openui).

## Phase 2 — static fixture

```bash
cd ui/review-console
npm install
npm run copy-fixture
npm run dev     # http://localhost:5177
npm run build   # verify production build
```

Fixture source: `docs/showcase/openui-luffy/review.openui` (from `scripts/review-to-openui.py`).

## Stack

- Vite + React
- `@openuidev/react-lang` `<Renderer />`
- `@openuidev/react-ui` `openuiChatLibrary`

See `docs/OPENUI-INTEGRATION.md` for the full phased plan.
