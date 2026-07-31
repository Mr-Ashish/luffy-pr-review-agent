# DEV — engineering knowledge

> How this part of the system is built.

## Architecture

- `pack/` holds installable templates that are *not* live workflows in this repo: `luffy-pr-review-caller.yml` is the F10 hub-managed thin caller, copied verbatim to `.github/workflows/luffy-pr-review.yml` on the target by `install-luffy.sh --caller`.
- It differs from this repo's own `luffy-pr-review.yml` in exactly one way: `uses:` is the absolute hub ref `Mr-Ashish/luffy-pr-review-agent/.github/workflows/luffy-review-reusable.yml@main` with literal `luffy_repository`/`luffy_ref` values, instead of the local `./.github/workflows/...` path with `github.repository`.
- Triggers, `permissions`, and the `luffy-${{ github.repository }}-<pr>` concurrency group are duplicated in the template because a `workflow_call` job cannot own them — edits to gating must be applied to `pack/luffy-pr-review-caller.yml` as well as the in-repo caller.
