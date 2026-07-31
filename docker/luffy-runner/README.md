# Luffy Hermes runner image (F8)

Prebaked Ubuntu image with **Hermes Agent** installed at the Luffy pin so CI jobs skip cold `install.sh` (~1–2 min).

## Build

From repo root:

```bash
./scripts/build-luffy-runner-image.sh
# PUSH=1 ./scripts/build-luffy-runner-image.sh   # also push to GHCR
```

CI: workflow **Build Luffy Hermes runner** (`.github/workflows/build-luffy-runner.yml`) builds on pin/Dockerfile changes and pushes:

`ghcr.io/<owner>/luffy-hermes-runner:<12-char-pin>` and `:latest`.

## Use with Luffy PR Review

1. Ensure the package is readable by Actions (public package, or grant the repo access).
2. Set repository variable **`LUFFY_RUNNER_IMAGE`** to the image ref, e.g.  
   `ghcr.io/mr-ashish/luffy-hermes-runner:53559aaf86b8`
3. Re-trigger `@luffy review` — the job runs in that container; `ensure_hermes` sees `LUFFY_HERMES_PREBAKED=1` / `/root/.hermes-pin` and skips install; Hermes Actions cache steps are skipped.

Leave `LUFFY_RUNNER_IMAGE` **unset** for the default path: `ubuntu-latest` + pin-keyed Hermes install cache (F2/F7/F14).

## Benchmark

```bash
SKIP_COLD=1 ./scripts/benchmark-hermes-startup.sh
# full (slow cold path):
./scripts/benchmark-hermes-startup.sh
```

Results land in `docs/benchmarks/hermes-startup-latest.{json,md}`.
