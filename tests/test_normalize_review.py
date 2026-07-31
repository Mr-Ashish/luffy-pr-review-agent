#!/usr/bin/env python3
"""Unit tests for normalize-review.py (stdlib only)."""

from __future__ import annotations

import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "normalize-review.py"


class NormalizeReviewTests(unittest.TestCase):
    def run_norm(self, raw: str, pr: str = "42", *, diff_truncated: bool = False) -> str:
        with tempfile.TemporaryDirectory() as td:
            inp = Path(td) / "raw.md"
            out = Path(td) / "out.md"
            inp.write_text(raw)
            cmd = [
                sys.executable,
                str(SCRIPT),
                "--input",
                str(inp),
                "--output",
                str(out),
                "--pr",
                pr,
                "--run-id",
                "test",
            ]
            if diff_truncated:
                cmd.append("--diff-truncated")
            subprocess.check_call(cmd)
            return out.read_text()

    def _full_contract(self, summary: str = "ok") -> str:
        return (
            "## 🏴‍☠️ Luffy Review — PR #42\n\n"
            "**Verdict:** APPROVE\n"
            "**Confidence:** high\n"
            "**Score:** 92/100\n"
            "**Review effort:** 2/5\n\n"
            f"### Summary\n{summary}\n\n"
            "### Walkthrough\n- change\n\n"
            "### Blocking\n- None\n\n"
            "### Key findings\nNone — no high-confidence defects in new code.\n\n"
            "### Security audit\nNo\n\n"
            "### Suggestions\n- None\n\n"
            "### Code suggestions\nNone\n\n"
            "### Nits\n- None\n\n"
            "### Tests & risk\n"
            "- Relevant tests added/updated: yes\n"
            "- Coverage: unit\n"
            "- Risk: low — small\n"
            "- Rollback: easy\n\n"
            "### What I checked\n- files\n"
        )

    def test_strips_outer_fence(self):
        raw = "```markdown\n" + self._full_contract() + "\n```"
        out = self.run_norm(raw)
        self.assertNotIn("```", out.splitlines()[0])
        self.assertIn("**Verdict:** APPROVE", out)
        self.assertIn("**Score:** 92/100", out)
        self.assertIn("### Security audit", out)
        self.assertIn("<!-- luffy-review pr=42 run=test -->", out)

    def test_repairs_missing_contract(self):
        raw = "looks fine ship it"
        out = self.run_norm(raw)
        self.assertIn("**Verdict:** COMMENT", out)
        self.assertIn("**Score:**", out)
        self.assertIn("### Summary", out)
        self.assertIn("### Security audit", out)
        self.assertIn("looks fine ship it", out)

    def test_redacts_openrouter_key_in_body(self):
        # F18: posted PR comments must never carry sk-or keys the model echoed.
        leak = "sk-or-v1-" + ("a" * 40)
        raw = self._full_contract(summary=f"found key {leak} in logs")
        out = self.run_norm(raw)
        self.assertNotIn(leak, out)
        self.assertIn("[OPENROUTER_KEY_REDACTED]", out)
        self.assertIn("**Verdict:** APPROVE", out)

    def test_redacts_openrouter_env_assignment(self):
        raw = self._full_contract(summary="export OPENROUTER_API_KEY=sk-secret-value-xyz")
        out = self.run_norm(raw)
        self.assertNotIn("sk-secret-value-xyz", out)
        self.assertIn("OPENROUTER_API_KEY=[REDACTED]", out)

    def test_redacts_github_tokens(self):
        ghp = "ghp_" + ("B" * 36)
        pat = "github_pat_" + ("C" * 22)
        raw = self._full_contract(summary=f"token {ghp} and {pat}")
        out = self.run_norm(raw)
        self.assertNotIn(ghp, out)
        self.assertNotIn(pat, out)
        self.assertIn("[GITHUB_TOKEN_REDACTED]", out)

    def test_redacts_secrets_in_contract_fallback_raw(self):
        leak = "sk-or-v1-" + ("d" * 40)
        out = self.run_norm(f"broken output with {leak}")
        self.assertNotIn(leak, out)
        self.assertIn("[OPENROUTER_KEY_REDACTED]", out)
        self.assertIn("### Raw agent output", out)

    def test_truncates_huge(self):
        raw = self._full_contract(summary="x" * 70_000)
        out = self.run_norm(raw)
        self.assertLessEqual(len(out), 60_500)
        self.assertIn("truncated", out.lower())

    def test_accepts_full_structured_contract(self):
        out = self.run_norm(self._full_contract("solid fix with tests"))
        self.assertIn("**Score:** 92/100", out)
        self.assertNotIn("contract repair", out.lower())

    def test_f27_diff_truncated_banner_before_verdict(self):
        out = self.run_norm(self._full_contract(), diff_truncated=True)
        self.assertIn("Diff truncated (F27)", out)
        self.assertIn("⚠️", out)
        # Banner must appear before the verdict line
        self.assertLess(out.index("Diff truncated (F27)"), out.index("**Verdict:**"))

    def test_f27_banner_idempotent(self):
        once = self.run_norm(self._full_contract(), diff_truncated=True)
        twice = self.run_norm(once, diff_truncated=True)
        self.assertEqual(once.count("Diff truncated (F27)"), 1)
        self.assertEqual(twice.count("Diff truncated (F27)"), 1)

    def test_f27_no_banner_when_full_diff(self):
        out = self.run_norm(self._full_contract(), diff_truncated=False)
        self.assertNotIn("Diff truncated (F27)", out)


if __name__ == "__main__":
    unittest.main()
