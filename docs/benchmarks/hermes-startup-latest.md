# Hermes startup benchmark

- **at:** `2026-07-31T12:23:37Z`
- **pin:** `53559aaf86b84dadae83cd9bb605ca476f9a0606`
- **image:** `ghcr.io/mr-ashish/luffy-hermes-runner:53559aaf86b8`
- **tarball_bytes:** `0`

| Path | Seconds | Meaning |
|------|--------:|---------|
| cold_install | skipped | Full install.sh in empty HOME |
| tarball_restore | 50.998 | Unpack pre-packed install (≈ Actions cache) |
| docker_prebake | n/a | Prebaked runner image |
| warm_present | 0.489 | Hermes already on PATH |

Lower is better for job startup. Prefer **cache hit** or **prebaked image** over cold install.

## How to reproduce

```bash
./scripts/build-luffy-runner-image.sh   # optional Docker prebake
./scripts/benchmark-hermes-startup.sh  # or SKIP_COLD=1 for quick paths only
```
