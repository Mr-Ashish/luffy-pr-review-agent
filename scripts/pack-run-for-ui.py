#!/usr/bin/env python3
"""Pack a Luffy .luffy-out / showcase run directory into a single JSON for the UI.

Usage:
  python3 scripts/pack-run-for-ui.py \\
    --dir docs/showcase/e2e-odoo-pr3-opus5-agentic-loop \\
    -o ui/review-console/public/fixtures/run-bundle.json

Optional overrides:
  --comment-url URL  --host modal|gha|local
"""

from __future__ import annotations

import argparse
import json
import re
import sys
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


def pack(dir_path: Path, *, comment_url: str = "", host: str = "gha") -> dict:
    meta = read_json(dir_path / "meta.json") or {}
    timings = read_json(dir_path / "timings.json") or {}
    usage = read_json(dir_path / "hermes-usage.json") or read_json(
        dir_path / "agent-loop" / "usage.json"
    ) or {}
    pr = read_json(dir_path / "pr.json") or {}
    trace = read_json(dir_path / "trace.json") or {}
    review_md = read_text(dir_path / "review.md") or ""
    review_raw = read_text(dir_path / "review.raw.md", 80_000)
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
    ap.add_argument("--dir", type=Path, required=True, help="Run directory")
    ap.add_argument("-o", "--out", type=Path, required=True)
    ap.add_argument("--comment-url", default="")
    ap.add_argument("--host", default="gha", choices=("gha", "modal", "local"))
    args = ap.parse_args()
    if not args.dir.is_dir():
        print(f"not a directory: {args.dir}", file=sys.stderr)
        return 1
    bundle = pack(args.dir, comment_url=args.comment_url, host=args.host)
    args.out.parent.mkdir(parents=True, exist_ok=True)
    args.out.write_text(json.dumps(bundle, indent=2) + "\n", encoding="utf-8")
    print(args.out)
    print(
        f"trace={bundle['run']['trace_id']} verdict={bundle['result'].get('verdict')} "
        f"files={len(bundle['trace']['artifacts'])}",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
