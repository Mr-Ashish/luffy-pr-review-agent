#!/usr/bin/env python3
"""Pack a Luffy .luffy-out / showcase run directory into a single JSON for the UI.

Usage:
  python3 scripts/pack-run-for-ui.py \\
    --dir docs/showcase/e2e-odoo-pr3-opus5-agentic-loop \\
    -o ui/review-console/public/fixtures/run-bundle.json

  # F31 pipeline (soft): pack TRACE_DIR after each review
  python3 scripts/pack-run-for-ui.py --dir \"$TRACE_DIR\" -o \"$OUT_DIR/run-bundle.json\"

Optional overrides:
  --comment-url URL  --host modal|gha|local
"""

from __future__ import annotations

import argparse
import json
import os
import re
import shutil
import sys
import tempfile
from pathlib import Path


def read_text(p: Path, limit: int = 400_000) -> str | None:
    if not p.is_file():
        return None
    t = p.read_text(encoding="utf-8", errors="replace")
    if len(t) > limit:
        return t[:limit] + f"\n\n… [truncated at {limit} chars] …\n"
    return t


def read_json(p: Path):
    if not p.is_file():
        return None
    try:
        return json.loads(p.read_text(encoding="utf-8", errors="replace"))
    except json.JSONDecodeError:
        return None


def parse_review(md: str) -> dict:
    def field(name: str) -> str:
        m = re.search(rf"^\*\*{re.escape(name)}:\*\*\s*(.+)$", md, re.M)
        return m.group(1).strip() if m else ""

    def section(heading: str) -> str:
        m = re.search(
            rf"^### {re.escape(heading)}\s*\n(.*?)(?=^### |\Z)",
            md,
            re.M | re.S,
        )
        return (m.group(1).strip() if m else "") or ""

    findings = []
    body = section("Key findings")
    for line in body.splitlines():
        line = line.strip()
        if not line.startswith("|") or re.match(r"^\|\s*-+", line):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 3 or cells[0].lower() in {"severity", "sev"}:
            continue
        findings.append(
            {
                "severity": cells[0],
                "file": cells[1] if len(cells) > 1 else "",
                "issue": cells[2] if len(cells) > 2 else "",
                "trigger": cells[3] if len(cells) > 3 else "",
            }
        )

    blocking = []
    for line in section("Blocking").splitlines():
        s = line.strip()
        if s.startswith(("- ", "* ")):
            blocking.append(re.sub(r"^[-*]\s+", "", s)[:500])

    return {
        "verdict": field("Verdict"),
        "score": field("Score"),
        "effort": field("Review effort"),
        "confidence": field("Confidence"),
        "summary": section("Summary"),
        "walkthrough": section("Walkthrough"),
        "blocking": blocking,
        "findings": findings,
        "security": section("Security audit") or field("Security audit"),
        "suggestions": section("Suggestions"),
    }


def detect_host(explicit: str | None = None) -> str:
    """Resolve host label for the Run Console (gha | modal | local)."""
    if explicit in ("gha", "modal", "local"):
        return explicit
    env_host = (os.environ.get("LUFFY_HOST") or "").strip().lower()
    if env_host in ("gha", "modal", "local"):
        return env_host
    if os.environ.get("MODAL_TASK_ID") or os.environ.get("MODAL_ENVIRONMENT"):
        return "modal"
    if os.environ.get("GITHUB_ACTIONS") == "true":
        return "gha"
    return "local"


def _resolve_review_md(dir_path: Path) -> str:
    """Prefer review.md; fall back to review-<pr>.md under OUT_DIR layouts."""
    direct = read_text(dir_path / "review.md")
    if direct:
        return direct
    candidates = sorted(
        p
        for p in dir_path.glob("review-*.md")
        if ".raw." not in p.name and p.is_file()
    )
    if candidates:
        return read_text(candidates[0]) or ""
    return ""


def prepare_pack_dir(dir_path: Path, *, extra_env_file: Path | None = None) -> Path:
    """Return a directory ready for pack() — copy memory-health if needed.

    If memory-health.env is only under OUT_DIR (not TRACE_DIR), soft-copy into a
    temp overlay so the bundle includes F30 health without mutating the trace.
    When the source already has everything, return dir_path unchanged.
    """
    mh_src = None
    if extra_env_file and extra_env_file.is_file():
        mh_src = extra_env_file
    elif (dir_path / "memory-health.env").is_file():
        return dir_path
    # Look next to common OUT_DIR layouts: parent of traces/<id>
    sibling = dir_path.parent.parent / "memory-health.env"
    if mh_src is None and sibling.is_file() and dir_path.parent.name == "traces":
        mh_src = sibling
    parent_mh = dir_path.parent / "memory-health.env"
    if mh_src is None and parent_mh.is_file():
        mh_src = parent_mh
    if mh_src is None or (dir_path / "memory-health.env").is_file():
        return dir_path
    # Overlay: temp dir with symlink/copy of files is heavy; just copy mh into
    # source when writable, else temp overlay with key files.
    try:
        shutil.copy2(mh_src, dir_path / "memory-health.env")
        return dir_path
    except OSError:
        pass
    tmp = Path(tempfile.mkdtemp(prefix="luffy-pack-"))
    for p in dir_path.iterdir():
        dest = tmp / p.name
        if p.is_dir():
            shutil.copytree(p, dest, dirs_exist_ok=True)
        else:
            shutil.copy2(p, dest)
    shutil.copy2(mh_src, tmp / "memory-health.env")
    return tmp


def pack(dir_path: Path, *, comment_url: str = "", host: str = "gha") -> dict:
    meta = read_json(dir_path / "meta.json") or {}
    timings = read_json(dir_path / "timings.json") or {}
    usage = read_json(dir_path / "hermes-usage.json") or read_json(
        dir_path / "agent-loop" / "usage.json"
    ) or {}
    pr = read_json(dir_path / "pr.json") or {}
    trace = read_json(dir_path / "trace.json") or {}
    review_md = _resolve_review_md(dir_path)
    review_raw = read_text(dir_path / "review.raw.md", 80_000)
    if not review_raw:
        raws = sorted(dir_path.glob("review-*.raw.md"))
        if raws:
            review_raw = read_text(raws[0], 80_000)
    prompt = read_text(dir_path / "prompt.md", 40_000)
    context = read_text(dir_path / "context.md", 40_000)
    diff = read_text(dir_path / "pr.diff", 120_000)
    memory = read_text(dir_path / "memory-after.md", 40_000)
    agent_loop_md = read_text(dir_path / "agent-loop" / "agent-loop.md", 80_000)
    agent_log = read_text(dir_path / "agent-loop" / "agent.log", 40_000) or read_text(
        dir_path / "hermes-run.log", 40_000
    )
    hermes_stderr = read_text(dir_path / "hermes.stderr", 20_000)
    files_txt = read_text(dir_path / "files.txt", 10_000)
    meta_env = read_text(dir_path / "meta.env", 5_000)
    memory_health = {}
    mh = dir_path / "memory-health.env"
    if mh.is_file():
        for line in mh.read_text().splitlines():
            if "=" in line and not line.startswith("#"):
                k, _, v = line.partition("=")
                memory_health[k.strip()] = v.strip()

    # Artifact inventory from meta or directory listing
    artifacts = []
    if isinstance(meta.get("files"), dict):
        for path, info in meta["files"].items():
            artifacts.append(
                {
                    "path": path,
                    "bytes": info.get("bytes") if isinstance(info, dict) else None,
                }
            )
    else:
        for p in sorted(dir_path.rglob("*")):
            if p.is_file() and p.name != "run-bundle.json":
                rel = str(p.relative_to(dir_path))
                artifacts.append({"path": rel, "bytes": p.stat().st_size})

    repo = meta.get("repo") or pr.get("url", "").replace("https://github.com/", "").rsplit(
        "/pull/", 1
    )[0]
    pr_number = str(meta.get("pr_number") or pr.get("number") or "")
    pr_url = pr.get("url") or (
        f"https://github.com/{repo}/pull/{pr_number}" if repo and pr_number else ""
    )

    return {
        "schema_version": 1,
        "host": host,
        "packed_from": str(dir_path),
        "run": {
            "trace_id": meta.get("trace_id") or f"pr{pr_number}-unknown",
            "run_id": str(meta.get("run_id") or ""),
            "run_attempt": str(meta.get("run_attempt") or "1"),
            "status": meta.get("status") or "unknown",
            "model": meta.get("model") or usage.get("model") or "unknown",
            "started_at": meta.get("started_at") or timings.get("started_at"),
            "ended_at": meta.get("ended_at") or timings.get("ended_at"),
            "total_seconds": timings.get("total_seconds"),
            "github_sha": meta.get("github_sha") or pr.get("commits", [{}])[-1].get("oid")
            if pr.get("commits")
            else meta.get("github_sha"),
            "github_ref": meta.get("github_ref"),
            "github_event_name": meta.get("github_event_name"),
            "trigger_comment": meta.get("trigger_comment") or "",
            "comment_url": comment_url,
            "hermes_rc": meta.get("hermes_rc"),
        },
        "pr": {
            "repo": repo,
            "number": pr_number,
            "title": pr.get("title") or "",
            "url": pr_url,
            "base": pr.get("baseRefName") or "",
            "head": pr.get("headRefName") or "",
            "author": (pr.get("author") or {}).get("login")
            if isinstance(pr.get("author"), dict)
            else pr.get("author") or "",
            "additions": pr.get("additions"),
            "deletions": pr.get("deletions"),
            "files": [
                {
                    "path": f.get("path"),
                    "additions": f.get("additions"),
                    "deletions": f.get("deletions"),
                }
                for f in (pr.get("files") or [])
                if isinstance(f, dict)
            ],
            "body": (pr.get("body") or "")[:4000],
        },
        "result": {
            **parse_review(review_md),
            "review_md": review_md,
            "review_raw_md": review_raw,
        },
        "cost": {
            "estimated_cost_usd": usage.get("estimated_cost_usd"),
            "cost_status": usage.get("cost_status"),
            "model": usage.get("model"),
            "total_tokens": usage.get("total_tokens"),
            "input_tokens": usage.get("input_tokens"),
            "output_tokens": usage.get("output_tokens"),
            "cache_read_tokens": usage.get("cache_read_tokens"),
            "cache_write_tokens": usage.get("cache_write_tokens"),
            "api_calls": usage.get("api_calls"),
            "provider": usage.get("provider"),
        },
        "timings": {
            "total_seconds": timings.get("total_seconds"),
            "stages": timings.get("stages") or [],
        },
        "memory": {
            "health": memory_health,
            "after_md": memory,
        },
        "trace": {
            "meta": meta,
            "trace_json": trace if isinstance(trace, dict) else {},
            "agent_loop_md": agent_loop_md,
            "agent_log": agent_log,
            "hermes_stderr": hermes_stderr,
            "prompt_md": prompt,
            "context_md": context,
            "files_txt": files_txt,
            "meta_env": meta_env,
            "artifacts": artifacts,
        },
        "diff": {
            "pr_diff": diff,
        },
    }


def main() -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    ap.add_argument("--dir", type=Path, required=True, help="Run / TRACE_DIR directory")
    ap.add_argument("-o", "--out", type=Path, required=True)
    ap.add_argument("--comment-url", default="")
    ap.add_argument(
        "--host",
        default=None,
        choices=("gha", "modal", "local"),
        help="Host label (default: auto-detect from env)",
    )
    ap.add_argument(
        "--memory-health",
        type=Path,
        default=None,
        help="Optional path to memory-health.env (F30) if not inside --dir",
    )
    ap.add_argument(
        "--also",
        type=Path,
        action="append",
        default=[],
        help="Extra output path(s) to write the same bundle (e.g. TRACE_DIR/run-bundle.json)",
    )
    ap.add_argument(
        "--soft",
        action="store_true",
        help="Exit 0 even when pack fails (pipeline must not fail reviews)",
    )
    args = ap.parse_args()
    try:
        if not args.dir.is_dir():
            raise FileNotFoundError(f"not a directory: {args.dir}")
        host = detect_host(args.host)
        pack_dir = prepare_pack_dir(args.dir, extra_env_file=args.memory_health)
        bundle = pack(pack_dir, comment_url=args.comment_url, host=host)
        if not bundle["result"].get("review_md") and not bundle["result"].get("verdict"):
            print("pack: no review.md found — writing minimal bundle", file=sys.stderr)
        outs = [args.out, *args.also]
        written = []
        for out in outs:
            out.parent.mkdir(parents=True, exist_ok=True)
            out.write_text(json.dumps(bundle, indent=2) + "\n", encoding="utf-8")
            written.append(out)
        for w in written:
            print(w)
        print(
            f"host={host} trace={bundle['run']['trace_id']} "
            f"verdict={bundle['result'].get('verdict') or '—'} "
            f"files={len(bundle['trace']['artifacts'])}",
            file=sys.stderr,
        )
        return 0
    except Exception as e:  # noqa: BLE001
        print(f"pack-run-for-ui failed: {e}", file=sys.stderr)
        if args.soft:
            return 0
        return 1


if __name__ == "__main__":
    raise SystemExit(main())
