#!/usr/bin/env python3
"""F9 (minimal): post path-anchored inline GitHub PR review comments.

Maps Key findings (+ Blocking bullets) to the first *added* line in pr.diff
for each file, then submits a COMMENT review with inline comments.

Usage:
  python3 scripts/post-inline-comments.py plan \\
    --review review.md --diff pr.diff

  python3 scripts/post-inline-comments.py post \\
    --review review.md --diff pr.diff --repo owner/name --pr 3 --commit SHA

Env:
  LUFFY_INLINE_COMMENTS=1 (default) | 0/off to skip
  LUFFY_INLINE_MAX=6
  LUFFY_INLINE_SEVERITY=critical,high   (comma list; empty = all)
  GH_TOKEN / GITHUB_TOKEN for post
  LUFFY_INLINE_FIXTURE=path.json  — write planned payload instead of API (tests)

Soft-fail policy: never raises for network; plan mode is pure offline.
"""

from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys
from pathlib import Path
from typing import Any


SEVERITY_RANK = {
    "critical": 0,
    "high": 1,
    "medium": 2,
    "low": 3,
    "info": 4,
    "blocking": 0,
}


def read_text(p: Path) -> str:
    return p.read_text(encoding="utf-8", errors="replace") if p.is_file() else ""


def normalize_path(raw: str) -> str:
    s = (raw or "").strip().strip("`").strip()
    s = s.split()[0] if s else ""
    # drop leading a/ b/ from diff style
    if s.startswith(("a/", "b/")):
        s = s[2:]
    return s


def parse_findings(review_md: str) -> list[dict[str, str]]:
    """Parse Key findings table + Blocking bullets into finding dicts."""
    findings: list[dict[str, str]] = []

    # Key findings table
    m = re.search(
        r"^### Key findings\s*\n(.*?)(?=^### |\Z)",
        review_md,
        re.M | re.S,
    )
    body = m.group(1) if m else ""
    for line in body.splitlines():
        line = line.strip()
        if not line.startswith("|") or re.match(r"^\|\s*-+", line):
            continue
        cells = [c.strip() for c in line.strip("|").split("|")]
        if len(cells) < 3:
            continue
        if cells[0].lower() in {"severity", "sev", "level"}:
            continue
        findings.append(
            {
                "severity": cells[0].lower(),
                "file": normalize_path(cells[1]),
                "issue": cells[2][:500],
                "trigger": cells[3][:300] if len(cells) > 3 else "",
                "source": "findings",
            }
        )

    # Blocking bullets: **`path` — text** or **path — text**
    bm = re.search(
        r"^### Blocking\s*\n(.*?)(?=^### |\Z)",
        review_md,
        re.M | re.S,
    )
    bbody = bm.group(1) if bm else ""
    for line in bbody.splitlines():
        s = line.strip()
        if not s.startswith(("- ", "* ")):
            continue
        s = re.sub(r"^[-*]\s+", "", s)
        # **`path` — issue** or **path — issue**
        mm = re.match(
            r"\*\*[`']?([^`'*]+?)[`']?\s*[—–-]\s*(.+?)\*\*",
            s,
        )
        if not mm:
            # path at start without bold close
            mm = re.match(r"[`']?([^\s`']+\.[a-zA-Z0-9]+)[`']?\s*[—–-]\s*(.+)", s)
        if not mm:
            continue
        path = normalize_path(mm.group(1))
        issue = mm.group(2).strip()[:500]
        # skip if already covered by findings table for same path+issue prefix
        findings.append(
            {
                "severity": "blocking",
                "file": path,
                "issue": issue,
                "trigger": "",
                "source": "blocking",
            }
        )

    return findings


def first_added_lines(diff_text: str) -> dict[str, int]:
    """Map path → first new-file line number that has an added (+) line."""
    result: dict[str, int] = {}
    current: str | None = None
    new_line = 0
    in_hunk = False

    for raw in diff_text.splitlines():
        if raw.startswith("diff --git "):
            current = None
            in_hunk = False
            continue
        if raw.startswith("+++ "):
            path = raw[4:].strip()
            if path == "/dev/null":
                current = None
                continue
            if path.startswith("b/"):
                path = path[2:]
            current = path
            continue
        if raw.startswith("@@"):
            # @@ -a,b +c,d @@
            mm = re.search(r"\+(\d+)(?:,\d+)?", raw)
            if mm:
                new_line = int(mm.group(1))
                in_hunk = True
            else:
                in_hunk = False
            continue
        if not in_hunk or current is None:
            continue
        if raw.startswith("+") and not raw.startswith("+++"):
            if current not in result:
                result[current] = new_line
            new_line += 1
        elif raw.startswith("-") and not raw.startswith("---"):
            # removed line — does not advance new file line
            pass
        else:
            # context line
            new_line += 1
    return result


def severity_allowed(sev: str, allow: set[str]) -> bool:
    if not allow:
        return True
    return sev.lower() in allow


def plan_comments(
    review_md: str,
    diff_text: str,
    *,
    max_n: int = 6,
    severities: set[str] | None = None,
) -> list[dict[str, Any]]:
    allow = severities if severities is not None else set()
    lines = first_added_lines(diff_text)
    findings = parse_findings(review_md)

    # Prefer higher severity; one comment per file (first wins after sort)
    findings.sort(key=lambda f: SEVERITY_RANK.get(f["severity"], 9))

    planned: list[dict[str, Any]] = []
    seen_files: set[str] = set()
    for f in findings:
        if not severity_allowed(f["severity"], allow):
            continue
        path = f["file"]
        if not path or path in seen_files:
            continue
        # resolve path: exact or suffix match against diff paths
        line = lines.get(path)
        if line is None:
            for dp, ln in lines.items():
                if dp.endswith("/" + path) or dp.endswith(path) or path.endswith(dp):
                    path = dp
                    line = ln
                    break
        if line is None:
            continue
        seen_files.add(path)
        body = f"**{f['severity'].upper()}** — {f['issue']}"
        if f.get("trigger"):
            body += f"\n\n_Trigger:_ {f['trigger']}"
        body += "\n\n<!-- luffy-inline -->"
        planned.append(
            {
                "path": path,
                "line": int(line),
                "side": "RIGHT",
                "body": body[:65000],
                "severity": f["severity"],
                "source": f["source"],
            }
        )
        if len(planned) >= max_n:
            break
    return planned


def enabled_from_env() -> bool:
    v = (os.environ.get("LUFFY_INLINE_COMMENTS") or "1").strip().lower()
    return v not in ("0", "false", "off", "no")


def severity_set_from_env() -> set[str]:
    raw = (os.environ.get("LUFFY_INLINE_SEVERITY") or "critical,high,blocking").strip()
    if not raw or raw.lower() in ("*", "all"):
        return set()
    return {x.strip().lower() for x in raw.split(",") if x.strip()}


def max_from_env() -> int:
    try:
        return max(1, min(20, int(os.environ.get("LUFFY_INLINE_MAX") or "6")))
    except ValueError:
        return 6


def post_review(
    repo: str,
    pr: int,
    commit: str,
    comments: list[dict[str, Any]],
    *,
    event: str = "COMMENT",
) -> dict[str, Any]:
    """Submit a PR review with inline comments via gh api."""
    if not comments:
        return {"ok": True, "posted": 0, "skipped": "no comments"}

    body = (
        "## 🏴‍☠️ Luffy inline findings (F9)\n\n"
        f"{len(comments)} path-anchored note(s) on the first changed line "
        "per file (see full review comment for context).\n\n"
        f"<!-- luffy-inline-review pr={pr} -->"
    )
    payload = {
        "commit_id": commit,
        "event": event,
        "body": body,
        "comments": [
            {
                "path": c["path"],
                "line": c["line"],
                "side": c.get("side") or "RIGHT",
                "body": c["body"],
            }
            for c in comments
        ],
    }

    # Fixture path first — offline tests need no token
    fixture = (os.environ.get("LUFFY_INLINE_FIXTURE") or "").strip()
    if fixture:
        Path(fixture).write_text(json.dumps(payload, indent=2) + "\n", encoding="utf-8")
        return {"ok": True, "posted": len(comments), "fixture": fixture}

    token = os.environ.get("GH_TOKEN") or os.environ.get("GITHUB_TOKEN") or ""
    if not token:
        return {"ok": False, "error": "GH_TOKEN/GITHUB_TOKEN missing"}

    proc = subprocess.run(
        [
            "gh",
            "api",
            "--method",
            "POST",
            "-H",
            "Accept: application/vnd.github+json",
            f"/repos/{repo}/pulls/{pr}/reviews",
            "--input",
            "-",
        ],
        input=json.dumps(payload),
        capture_output=True,
        text=True,
        check=False,
        env={**os.environ, "GH_TOKEN": token, "GITHUB_TOKEN": token},
    )
    if proc.returncode != 0:
        return {
            "ok": False,
            "error": (proc.stderr or proc.stdout or "gh api failed")[-800:],
            "posted": 0,
        }
    try:
        data = json.loads(proc.stdout or "{}")
    except json.JSONDecodeError:
        data = {}
    return {
        "ok": True,
        "posted": len(comments),
        "review_id": data.get("id"),
        "html_url": data.get("html_url"),
    }


def main(argv: list[str] | None = None) -> int:
    ap = argparse.ArgumentParser(description=__doc__)
    sub = ap.add_subparsers(dest="cmd", required=True)

    def add_common(p: argparse.ArgumentParser) -> None:
        p.add_argument("--review", type=Path, required=True)
        p.add_argument("--diff", type=Path, required=True)
        p.add_argument("--max", type=int, default=None)
        p.add_argument(
            "--severity",
            default=None,
            help="Comma list (default env LUFFY_INLINE_SEVERITY or critical,high,blocking)",
        )

    p_plan = sub.add_parser("plan", help="Offline plan (JSON to stdout)")
    add_common(p_plan)

    p_post = sub.add_parser("post", help="Post inline review comments via gh")
    add_common(p_post)
    p_post.add_argument("--repo", required=True)
    p_post.add_argument("--pr", type=int, required=True)
    p_post.add_argument("--commit", default="", help="Head SHA (required unless fixture)")
    p_post.add_argument(
        "--force",
        action="store_true",
        help="Ignore LUFFY_INLINE_COMMENTS=0",
    )

    args = ap.parse_args(argv)
    review_md = read_text(args.review)
    diff_text = read_text(args.diff)
    max_n = args.max if args.max is not None else max_from_env()
    if args.severity is not None:
        sev = (
            set()
            if args.severity.strip().lower() in ("*", "all", "")
            else {x.strip().lower() for x in args.severity.split(",") if x.strip()}
        )
    else:
        sev = severity_set_from_env()

    comments = plan_comments(review_md, diff_text, max_n=max_n, severities=sev)

    if args.cmd == "plan":
        print(
            json.dumps(
                {
                    "ok": True,
                    "count": len(comments),
                    "comments": comments,
                    "files_in_diff": len(first_added_lines(diff_text)),
                },
                indent=2,
            )
        )
        return 0

    # post
    if not args.force and not enabled_from_env():
        print(json.dumps({"ok": True, "skipped": "LUFFY_INLINE_COMMENTS off", "posted": 0}))
        return 0
    if not comments:
        print(json.dumps({"ok": True, "posted": 0, "skipped": "no mappable findings"}))
        return 0
    commit = (args.commit or os.environ.get("HEAD_SHA") or "").strip()
    if not commit and not (os.environ.get("LUFFY_INLINE_FIXTURE") or "").strip():
        print(
            json.dumps({"ok": False, "error": "commit SHA required", "posted": 0}),
            file=sys.stderr,
        )
        return 0  # soft
    result = post_review(args.repo, args.pr, commit or "0" * 40, comments)
    print(json.dumps(result, indent=2))
    return 0  # always soft for pipeline


if __name__ == "__main__":
    raise SystemExit(main())
