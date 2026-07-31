```json
{
  "summary": "Most of the session restates already-indexed architecture/install/verdict claims. Genuinely new durable items: the concrete correctness pitfalls behind F13/F14/F15 (sparse-path count bug, cache save-on-miss, config-error exit code), MEMORY.md rotation cap, the GITHUB_TOKEN/repository_dispatch 403 constraint that makes direct push the default hub mode, and the manual workflow_dispatch trigger path.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": ".",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- Sparse-checkout path counting is fragile (F13): `grep -c ... || echo 0` emitted `0\\n0` for an empty PR path list, which the workflow read as non-zero and fell back to a **full monorepo clone** (observed ~3.5 min on Odoo with `fetch-depth: 0`). Any change to `scripts/sparse-pr-paths.sh` must keep the count a single integer.\n- The Hermes Actions cache must be saved **only on miss** with a stable key (F14); an earlier key including `run_id` thrashed the cache (never a hit, burned GH cache quota). Symptom to watch for: `cache write denied` even with `actions: write`.\n- Config errors must exit non-zero (F15): a missing-secret path returned `pipeline_rc=0`, so the trigger comment got a false ✅ reaction while no review happened. Reaction/status honesty depends on the pipeline exit code, not on whether a comment was posted.\n- `MEMORY.md` is not unbounded: it is appended by `distill-memory.sh` and **rotates** when it exceeds `MAX_MEMORY_BYTES` (default 100000), so long-lived memory facts can be dropped silently — treat distilled memory as lossy, not as a durable store."
    ,
      "evidence": [
        "F13 | Fix sparse path `grep -c || echo 0` → empty PR path count was `0\\n0`, forcing full monorepo clone",
        "F14 | Hermes cache: stable key `v3`, save only on miss (drop per-run_id thrash)",
        "F15 | Config error `pipeline_rc=1` (was 0 → false ✅ reaction)",
        "Rotates when exceeding `MAX_MEMORY_BYTES` (default 100000)"
      ],
      "confidence": "high"
    },
    {
      "kind": "dev",
      "path": "memory",
      "action": "merge",
      "section": "Pitfalls",
      "content": "- `direct` is the default hub mode because `GITHUB_TOKEN` **cannot** call `repository_dispatch` (HTTP 403); the `dispatch` path (`.github/workflows/ingest-luffy-run.yml`, event type `luffy-run`) only works with a classic PAT supplied by the target repo.\n- Direct push therefore needs write on the hub: on the hub repo itself `GITHUB_TOKEN` + `contents: write` is sufficient (self-review), but any *other* target repo requires `LUFFY_HUB_TOKEN` (PAT with contents write on the hub) or hub publishing silently degrades.\n- Original failure mode this layer exists to fix: hub memory was written after a run but **not loaded into** the next review — the preload step is the load half of the contract, and without it the `memory/` tree is write-only."
    ,
      "evidence": [
        "`GITHUB_TOKEN` cannot call `repository_dispatch` (HTTP 403)",
        "When Luffy runs on the hub repo itself, `GITHUB_TOKEN` + `contents: write` is enough for direct ingest",
        "Hub memory | Written after run, not loaded into next review"
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": ".",
      "action": "merge",
      "section": "Common commands",
      "content": "- Manual (no PR comment) trigger: GitHub **Actions → Luffy PR Review → Run workflow → enter PR number**. `workflow_dispatch` also bypasses the F19 cooldown.\n- Force a paid re-review inside the cooldown window with the comment `@luffy review force`, or disable the window entirely via `vars.LUFFY_COOLDOWN_SECONDS=0` / `off`.\n- Regenerate the Hermes startup comparison: `./scripts/benchmark-hermes-startup.sh` writes `docs/benchmarks/hermes-startup-latest.md` (cold Hermes install measured at ~1–2 min, which is what the cache/prebaked-image paths are traded against)."
    ,
      "evidence": [
        "Actions → **Luffy PR Review** → Run workflow → enter PR number.",
        "Bypass: `@luffy review force`, `workflow_dispatch`, or set cooldown to `0`/`off`",
        "**Benchmark:** `./scripts/benchmark-hermes-startup.sh` → `docs/benchmarks/hermes-startup-latest.md`"
      ],
      "confidence": "medium"
    }
  ]
}
```
