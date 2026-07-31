```json
{
  "summary": "The session's F8 prebaked-runner work is largely already captured in root DEV.md/USAGE.md, but the image-side contract and GHCR wiring for docker/luffy-runner is not yet documented at that path: the Dockerfile's prebaked markers, pin-derived tagging, build-script smoke gate, and the package-visibility prerequisite for using the image as an Actions container.",
  "session_ids": ["dogfood-luffy-session"],
  "units": [
    {
      "kind": "dev",
      "path": "docker/luffy-runner",
      "action": "merge",
      "section": "Design decisions",
      "content": "- The image's job is to satisfy a two-signal contract that CI probes, not to run Luffy itself: it sets `LUFFY_HERMES_PREBAKED=1` and writes the resolved SHA to `/root/.hermes-pin`, and bakes `PATH=/root/.local/bin:/root/.hermes/bin`. `ensure_hermes` short-circuits when either signal is present *and* `hermes` is on PATH, so a broken/renamed marker silently falls back to a cold install instead of failing loudly.\n- Base is plain `ubuntu:24.04` plus the minimum Hermes needs (`ca-certificates curl git python3 python3-venv bash build-essential`); Hermes is installed at build time with `install.sh --skip-setup --commit \"${HERMES_COMMIT}\" --force-commit`, i.e. the same pinned, non-interactive install path CI uses (F7).\n- The pin is an `ARG HERMES_COMMIT` with a hardcoded default that must track `scripts/hermes-pin.sh` DEFAULT — `scripts/build-luffy-runner-image.sh` resolves the pin via `scripts/hermes-pin.sh default` (overridable with `HERMES_COMMIT=…`) and passes it as `--build-arg`, so the Dockerfile default only matters for raw `docker build` invocations.\n- Tagging is pin-derived, not semver: `ghcr.io/<owner>/luffy-hermes-runner:<first-12-chars-of-pin>` plus `:latest`, which makes the image ref self-documenting about which Hermes commit is inside.\n- The build script gates publication on a smoke run (`docker run --rm <tag> hermes --version`) before any push, and only pushes when `PUSH=1`; the GHCR workflow (`.github/workflows/build-luffy-runner.yml`) rebuilds on pin/Dockerfile changes.",
      "evidence": [
        "ENV DEBIAN_FRONTEND=noninteractive LUFFY_HERMES_PREBAKED=1 PATH=\"/root/.local/bin:/root/.hermes/bin:${PATH}\"",
        "printf '%s\\n' \"${HERMES_COMMIT}\" >/root/.hermes-pin",
        "PIN=\"$(\"$ROOT/scripts/hermes-pin.sh\" default | tr -d '\\n')\"; SHORT=\"${PIN:0:12}\"",
        "log \"Smoke: hermes --version in image\"; docker run --rm \"$TAG_PIN\" hermes --version",
        "# Pin must match scripts/hermes-pin.sh DEFAULT (or pass HERMES_COMMIT=...)."
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": "docker/luffy-runner",
      "action": "merge",
      "section": "Setup",
      "content": "- Order of operations to adopt the prebaked runner: (1) publish the image (`PUSH=1 ./scripts/build-luffy-runner-image.sh` or the **Build Luffy Hermes runner** workflow), (2) make the GHCR package readable by Actions — public package, or explicitly grant the consuming repo access, (3) set repo variable `LUFFY_RUNNER_IMAGE` to the pin-tagged ref (e.g. `ghcr.io/mr-ashish/luffy-hermes-runner:53559aaf86b8`), (4) re-trigger `@luffy review`.\n- The workflow resolves the container as `${{ vars.LUFFY_RUNNER_IMAGE != '' && vars.LUFFY_RUNNER_IMAGE || null }}`, so leaving the variable unset (or empty) is the supported default path: host `ubuntu-latest` + pin-keyed Hermes install cache. There is no separate on/off flag.\n- Verify an image locally before wiring it into CI: `docker run --rm ghcr.io/mr-ashish/luffy-hermes-runner:latest hermes --version`.",
      "evidence": [
        "Ensure the package is readable by Actions (public package, or grant the repo access).",
        "container: ${{ vars.LUFFY_RUNNER_IMAGE != '' && vars.LUFFY_RUNNER_IMAGE || null }}",
        "Leave `LUFFY_RUNNER_IMAGE` **unset** for the default path: `ubuntu-latest` + pin-keyed Hermes install cache (F2/F7/F14)."
      ],
      "confidence": "high"
    },
    {
      "kind": "usage",
      "path": "docker/luffy-runner",
      "action": "merge",
      "section": "Troubleshooting",
      "content": "- If a review job still spends 1–2 min installing Hermes while `LUFFY_RUNNER_IMAGE` is set, check the job log for the `F8 prebaked Hermes detected …; skipping install cache` notice: the workflow's *Detect prebaked Hermes* step is what disables the cache save/restore steps, and it only fires when `hermes` is on PATH inside the container.\n- A stale `LUFFY_RUNNER_IMAGE` pin is invisible: the prebaked short-circuit returns before any pin comparison, so a container built from an older `HERMES_COMMIT` will run happily against a newer `scripts/hermes-pin.sh` default. Compare the image tag's 12-char pin against `scripts/hermes-pin.sh default` when Hermes behaviour differs between the container path and the host path.\n- Self-hosted runners can opt into the same fast path without the image by placing `hermes` on PATH plus a `/root/.hermes-pin` (or `$HOME/.hermes-pin`) marker file.",
      "evidence": [
        "echo \"::notice::F8 prebaked Hermes detected ($(command -v hermes)); skipping install cache\"",
        "if [[ \"${LUFFY_HERMES_PREBAKED:-}\" == \"1\" || -f /root/.hermes-pin || -f \"${HOME}/.hermes-pin\" ]] && command -v hermes >/dev/null 2>&1; then ... return",
        "# F8: prebaked image (LUFFY_RUNNER_IMAGE) or self-hosted with /root/.hermes-pin + hermes on PATH."
      ],
      "confidence": "medium"
    }
  ]
}
```
