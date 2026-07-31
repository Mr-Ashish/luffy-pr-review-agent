#!/usr/bin/env python3
"""F21: surface Hermes/OpenRouter cost + tokens on PR comments and job summaries.

Reads hermes --usage-file JSON (see run-hermes-review.sh) and emits:
  footer        — one Markdown italic line for the posted review
  append        — inject/update that line on an existing review.md
  step-summary  — Markdown section for $GITHUB_STEP_SUMMARY

Missing or empty usage files are soft no-ops (exit 0) so the pipeline never
fails because cost telemetry was absent.
"""

from __future__ import annotations

import argparse
import json
import re
import sys
from pathlib import Path
from typing import Any

# Matches the brand footer normalize-review.py appends.
_FOOTER_RX = re.compile(
    r"^\*Luffy · Hermes Agent · OpenRouter · memory-backed review[^*]*\*\s*$",
    re.M,
)
_COST_LINE_RX = re.compile(r"^\*Cost / usage:.*\*\s*$", re.M)


def load_usage(path: Path | None) -> dict[str, Any] | None:
    if path is None or not path.is_file():
        return None
    try:
        raw = path.read_text(encoding="utf-8", errors="replace").strip()
        if not raw:
            return None
        data = json.loads(raw)
    except (OSError, json.JSONDecodeError):
        return None
    if not isinstance(data, dict) or not data:
        return None
    return data


def load_timings(path: Path | None) -> dict[str, Any] | None:
    if path is None or not path.is_file():
        return None
    try:
        data = json.loads(path.read_text(encoding="utf-8", errors="replace"))
    except (OSError, json.JSONDecodeError):
        return None
    return data if isinstance(data, dict) else None


def _num(v: Any) -> float | int | None:
    if isinstance(v, bool):
        return None
    if isinstance(v, (int, float)):
        return v
    return None


def format_tokens(n: float | int | None) -> str:
    if n is None:
        return "n/a"
    n = int(n)
    if n >= 1_000_000:
        return f"{n / 1_000_000:.1f}M"
    if n >= 10_000:
        return f"{n / 1_000:.0f}k"
    if n >= 1_000:
        return f"{n / 1_000:.1f}k"
    return str(n)


def format_cost_usd(v: float | int | None) -> str:
    if v is None:
        return "n/a"
    x = float(v)
    if x >= 1:
        return f"${x:.2f}"
    if x >= 0.01:
        return f"${x:.2f}"
    if x > 0:
        return f"${x:.4f}"
    return "$0"


def format_footer_line(usage: dict[str, Any]) -> str:
    """Single italic Markdown line (no leading ---)."""
    model = str(usage.get("model") or usage.get("model_id") or "unknown")
    cost = format_cost_usd(_num(usage.get("estimated_cost_usd")))
    total = format_tokens(_num(usage.get("total_tokens")))
    api_calls = _num(usage.get("api_calls"))
    calls_s = str(int(api_calls)) if api_calls is not None else "n/a"
    status = str(usage.get("cost_status") or "").strip()
    cost_note = f" ({status})" if status and status not in {"ok", "exact"} else ""
    return (
        f"*Cost / usage: model=`{model}` · ~{cost}{cost_note} · "
        f"{total} tokens · {calls_s} API calls*"
    )


def format_step_summary(
    usage: dict[str, Any] | None,
    timings: dict[str, Any] | None = None,
) -> str:
    lines = ["### Luffy cost / usage (F21)", ""]
    if usage is None:
        lines.append("_No `hermes-usage.json` for this run (install failure or runner skip)._")
        lines.append("")
        return "\n".join(lines)

    model = usage.get("model") or usage.get("model_id") or "unknown"
    cost = format_cost_usd(_num(usage.get("estimated_cost_usd")))
    status = usage.get("cost_status") or "n/a"
    source = usage.get("cost_source") or "n/a"
    lines.extend(
        [
            f"- **Model:** `{model}`",
            f"- **Estimated cost:** {cost} (`{status}` via `{source}`)",
            f"- **Tokens:** in={format_tokens(_num(usage.get('input_tokens')))} · "
            f"out={format_tokens(_num(usage.get('output_tokens')))} · "
            f"total={format_tokens(_num(usage.get('total_tokens')))}",
            f"- **Cache tokens:** read={format_tokens(_num(usage.get('cache_read_tokens')))} · "
            f"write={format_tokens(_num(usage.get('cache_write_tokens')))}",
            f"- **API calls:** {_num(usage.get('api_calls')) if _num(usage.get('api_calls')) is not None else 'n/a'}",
        ]
    )
    if usage.get("session_id"):
        lines.append(f"- **Session:** `{usage['session_id']}`")
    if timings and _num(timings.get("total_seconds")) is not None:
        lines.append(f"- **Pipeline wall time:** {int(timings['total_seconds'])}s")
        stages = timings.get("stages") or []
        if isinstance(stages, list) and stages:
            bits = []
            for s in stages:
                if not isinstance(s, dict):
                    continue
                name = s.get("name", "?")
                sec = s.get("seconds", "?")
                bits.append(f"{name}={sec}s")
            if bits:
                lines.append(f"- **Stages:** {', '.join(bits)}")
    lines.append("")
    return "\n".join(lines)


def append_footer_to_review(review_path: Path, usage: dict[str, Any]) -> bool:
    """Inject cost line into review.md. Returns True if file changed."""
    text = review_path.read_text(encoding="utf-8", errors="replace")
    cost_line = format_footer_line(usage)

    if _COST_LINE_RX.search(text):
        new_text = _COST_LINE_RX.sub(cost_line, text, count=1)
    elif _FOOTER_RX.search(text):
        # Place cost line immediately after brand footer
        new_text = _FOOTER_RX.sub(lambda m: m.group(0).rstrip() + "\n" + cost_line, text, count=1)
    else:
        body = text.rstrip() + "\n\n---\n" + cost_line + "\n"
        new_text = body

    if not new_text.endswith("\n"):
        new_text += "\n"
    if new_text == text:
        return False
    review_path.write_text(new_text, encoding="utf-8")
    return True


def main(argv: list[str] | None = None) -> int:
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument(
        "mode",
        choices=("footer", "append", "step-summary"),
        help="footer=print line; append=mutate review; step-summary=Actions summary MD",
    )
    p.add_argument(
        "--usage",
        type=Path,
        default=None,
        help="Path to hermes-usage.json (default: $OUT_DIR/hermes-usage.json)",
    )
    p.add_argument("--review", type=Path, default=None, help="review.md for append mode")
    p.add_argument("--timings", type=Path, default=None, help="timings.json for step-summary")
    p.add_argument(
        "--out",
        type=Path,
        default=None,
        help="Optional write path (default: stdout for footer/step-summary)",
    )
    args = p.parse_args(argv)

    usage_path = args.usage
    if usage_path is None:
        out_dir = Path(__import__("os").environ.get("OUT_DIR", "."))
        usage_path = out_dir / "hermes-usage.json"

    usage = load_usage(usage_path)

    if args.mode == "footer":
        if usage is None:
            return 0
        line = format_footer_line(usage) + "\n"
        if args.out:
            args.out.write_text(line, encoding="utf-8")
        else:
            sys.stdout.write(line)
        return 0

    if args.mode == "append":
        if usage is None:
            print("usage-summary: no usage file; skip append", file=sys.stderr)
            return 0
        if args.review is None or not args.review.is_file():
            print("usage-summary: --review required for append", file=sys.stderr)
            return 1
        changed = append_footer_to_review(args.review, usage)
        print(
            f"usage-summary: {'updated' if changed else 'unchanged'} {args.review}",
            file=sys.stderr,
        )
        return 0

    # step-summary
    timings = load_timings(args.timings)
    md = format_step_summary(usage, timings)
    if args.out:
        args.out.write_text(md, encoding="utf-8")
    else:
        sys.stdout.write(md)
    return 0


if __name__ == "__main__":
    sys.exit(main())
