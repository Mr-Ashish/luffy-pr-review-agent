# Meta-loop optimizations

Log ≤5 concrete process deltas per fire. Prefer implementable Luffy/docs changes over theater.

## 2026-07-31 — milvus harness cold-start

1. **Eval port ROI:** for large monorepos (milvus), **exact parent/head SHA branches** beat `gh pr diff` apply-on-tip — zero-conflict 6-file delta, fair e2e.
2. **Clone budget:** `git clone --filter=blob:none --depth 1` of milvus fork ≈158MB — enough for assemble/diff; no full history tax.
3. **Harness research:** agent harness = loop + tools + memory + stop/budget (control plane > model). Luffy already owns gates (F45/F49) and traces; keep product judgment in prompts only.
4. **Corpus-first stop condition:** when LIVE target has 0 eval PRs, one fire = port + one live mini run before product worktrees (unblocks all later e2e).
5. **Idle reset:** milvus corpus+e2e progress → `loop-idle-streak` = 0.

## Applied next-fire defaults

- Prefer milvus corpus growth until ≥2–3 PRs before pure product fires.
- Cap active worktrees ≤3 under `pr-review-agent-wt/`.
- One primary outcome per fire (port | e2e | product), not all three.

## 2026-07-31 — corpus 1→2 + memory compound

1. **ROI choice:** corpus growth > new product when n_eval < 3 — second PR unblocks multi-PR e2e compare.
2. **Memory feedback loop:** second milvus run preloaded local MEMORY from #1 → measurable D8 3→4 without hub.
3. **Diversity metric:** prefer multi-lang/config PRs (#51962) after pure-Go (#51991) for multi-lens stress.
4. **Stop idle:** progress (port+e2e) → streak 0; still need one more corpus PR for ≥3 target.
5. **Next-fire default:** either #3 port OR F60 thread-reply if e2e signal plateaus.
