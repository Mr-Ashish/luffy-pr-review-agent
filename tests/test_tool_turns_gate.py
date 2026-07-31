#!/usr/bin/env python3
"""F45: tool_turns_gate (H12 fail closed on zero tools)."""

from __future__ import annotations

import json
import os
import subprocess
import sys
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "tool_turns_gate.py"
sys.path.insert(0, str(ROOT / "scripts"))

import importlib.util

_spec = importlib.util.spec_from_file_location("tool_turns_gate", SCRIPT)
assert _spec and _spec.loader
_mod = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(_mod)


class DecideTests(unittest.TestCase):
    def test_tools_used_no_gate(self):
        d = _mod.decide(tool_turns=3, file_count=4, paths=["a.py", "b.py"])
        self.assertEqual(d["gate"], 0)
        self.assertEqual(d["reason"], "tools_used")

    def test_zero_tools_multi_file_gates(self):
        d = _mod.decide(tool_turns=0, file_count=4, paths=["a.js", "b.js", "c.js"])
        self.assertEqual(d["gate"], 1)
        self.assertEqual(d["reason"], "zero_tools_multi_file_code")
        self.assertEqual(d["action"], "downgrade_approve")

    def test_docs_only_skips(self):
        d = _mod.decide(
            tool_turns=0,
            file_count=3,
            paths=["README.md", "docs/x.md", "CHANGELOG.md"],
        )
        self.assertEqual(d["gate"], 0)
        self.assertEqual(d["reason"], "docs_only")
        self.assertTrue(d["docs_only"])

    def test_single_file_below_min(self):
        d = _mod.decide(tool_turns=0, file_count=1, paths=["only.py"], min_files_n=2)
        self.assertEqual(d["gate"], 0)
        self.assertEqual(d["reason"], "below_min_files")

    def test_gate_off(self):
        d = _mod.decide(tool_turns=0, file_count=5, paths=["a.py", "b.py"], gate_on=False)
        self.assertEqual(d["gate"], 0)
        self.assertEqual(d["reason"], "gate_off")

    def test_nontarget_verdict_annotate_only(self):
        d = _mod.decide(
            tool_turns=0,
            file_count=3,
            paths=["a.py", "b.py"],
            verdict="REQUEST_CHANGES",
        )
        self.assertEqual(d["gate"], 1)
        self.assertEqual(d["action"], "annotate_only")


class ApplyTests(unittest.TestCase):
    SAMPLE = """## 🏴‍☠️ Luffy Review — PR #2

**Verdict:** APPROVE
**Confidence:** medium
**Score:** 90/100
**Review effort:** 2/5

### Summary
Looks good enough.

### Blocking
- None
"""

    def test_downgrade_approve(self):
        d = _mod.decide(tool_turns=0, file_count=4, paths=["a.js", "b.js"])
        new, mut = _mod.apply_to_review(self.SAMPLE, decision=d)
        self.assertTrue(mut["mutated"])
        self.assertEqual(mut["verdict_before"], "APPROVE")
        self.assertEqual(mut["verdict_after"], "COMMENT")
        self.assertIn("**Verdict:** COMMENT", new)
        self.assertIn("**Confidence:** low", new)
        self.assertIn("**Score:** 55/100", new)
        self.assertIn("Incomplete agentic review (F45)", new)
        self.assertTrue(mut["banner_added"])

    def test_idempotent_banner(self):
        d = _mod.decide(tool_turns=0, file_count=4, paths=["a.js", "b.js"])
        once, _ = _mod.apply_to_review(self.SAMPLE, decision=d)
        twice, mut2 = _mod.apply_to_review(once, decision=d)
        self.assertEqual(once.count("Incomplete agentic review (F45)"), 1)
        # second apply still COMMENT; banner not duplicated
        self.assertEqual(twice.count("Incomplete agentic review (F45)"), 1)
        self.assertEqual(mut2["verdict_after"], "COMMENT")

    def test_no_mutate_when_tools(self):
        d = _mod.decide(tool_turns=2, file_count=4, paths=["a.js", "b.js"])
        new, mut = _mod.apply_to_review(self.SAMPLE, decision=d)
        self.assertFalse(mut["mutated"])
        self.assertEqual(new, self.SAMPLE)


class CliTests(unittest.TestCase):
    def test_decide_cli(self):
        r = subprocess.run(
            [
                sys.executable,
                str(SCRIPT),
                "decide",
                "--tool-turns",
                "0",
                "--file-count",
                "4",
                "--path",
                "a.js",
                "--path",
                "b.js",
            ],
            capture_output=True,
            text=True,
            check=False,
        )
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("gate=1", r.stdout)
        self.assertIn("reason=zero_tools_multi_file_code", r.stdout)

    def test_apply_cli_and_env(self):
        with tempfile.TemporaryDirectory() as td:
            td_p = Path(td)
            rev = td_p / "review.md"
            rev.write_text(
                "**Verdict:** APPROVE\n**Confidence:** high\n**Score:** 88/100\n\n### Summary\nok\n",
                encoding="utf-8",
            )
            loop = td_p / "agent-loop.json"
            loop.write_text(json.dumps({"tool_call_turns": 0}), encoding="utf-8")
            env_out = td_p / "tool-turns-gate.env"
            r = subprocess.run(
                [
                    sys.executable,
                    str(SCRIPT),
                    "apply",
                    "--review",
                    str(rev),
                    "--loop-json",
                    str(loop),
                    "--file-count",
                    "3",
                    "--path",
                    "x.py",
                    "--path",
                    "y.py",
                    "--env-out",
                    str(env_out),
                ],
                capture_output=True,
                text=True,
                check=False,
            )
            self.assertEqual(r.returncode, 0, r.stderr)
            body = rev.read_text(encoding="utf-8")
            self.assertIn("**Verdict:** COMMENT", body)
            self.assertTrue(env_out.is_file())
            env_txt = env_out.read_text(encoding="utf-8")
            self.assertIn("gate=1", env_txt)
            self.assertIn("mutated=1", env_txt)

    def test_enabled_env_off(self):
        env = os.environ.copy()
        env["LUFFY_TOOL_TURNS_GATE"] = "off"
        r = subprocess.run(
            [
                sys.executable,
                str(SCRIPT),
                "decide",
                "--tool-turns",
                "0",
                "--file-count",
                "5",
                "--path",
                "a.py",
                "--path",
                "b.py",
            ],
            capture_output=True,
            text=True,
            env=env,
            check=False,
        )
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertIn("gate=0", r.stdout)
        self.assertIn("reason=gate_off", r.stdout)


class WireTests(unittest.TestCase):
    def test_run_hermes_mentions_f45(self):
        text = (ROOT / "scripts" / "run-hermes-review.sh").read_text(encoding="utf-8")
        self.assertIn("tool_turns_gate.py", text)
        self.assertIn("F45", text)
        self.assertIn("tool-turns-gate.env", text)

    def test_install_pack_lists_script(self):
        text = (ROOT / "scripts" / "install-luffy.sh").read_text(encoding="utf-8")
        self.assertIn("tool_turns_gate.py", text)


if __name__ == "__main__":
    unittest.main()
