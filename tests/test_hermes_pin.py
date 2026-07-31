"""F7: hermes-pin.sh resolve / install-args / matches / cache-suffix."""

from __future__ import annotations

import os
import subprocess
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
PIN = ROOT / "scripts" / "hermes-pin.sh"
DEFAULT = "53559aaf86b84dadae83cd9bb605ca476f9a0606"


def _run(args: list[str], env: dict[str, str] | None = None) -> subprocess.CompletedProcess:
    base = {**os.environ, **(env or {})}
    # Drop inherited pin unless the test set it (including explicit empty).
    if env is None or "LUFFY_HERMES_COMMIT" not in env:
        base.pop("LUFFY_HERMES_COMMIT", None)
    return subprocess.run(
        ["bash", str(PIN), *args],
        capture_output=True,
        text=True,
        env=base,
        check=False,
    )


class HermesPinTests(unittest.TestCase):
    def test_default_resolve(self):
        r = _run(["resolve"])
        self.assertEqual(r.returncode, 0, r.stderr)
        self.assertEqual(r.stdout.strip(), DEFAULT)

    def test_default_subcommand(self):
        r = _run(["default"])
        self.assertEqual(r.returncode, 0)
        self.assertEqual(r.stdout.strip(), DEFAULT)

    def test_floating_aliases(self):
        for alias in ("latest", "main", "floating", ""):
            r = _run(["resolve"], env={"LUFFY_HERMES_COMMIT": alias})
            self.assertEqual(r.returncode, 0, alias)
            self.assertEqual(r.stdout.strip(), "", msg=f"alias={alias!r}")

    def test_explicit_sha(self):
        sha = "deadbeefcafebabe0123456789abcdef01234567"
        r = _run(["resolve"], env={"LUFFY_HERMES_COMMIT": sha})
        self.assertEqual(r.stdout.strip(), sha)

    def test_install_args_pinned(self):
        r = _run(["install-args"])
        self.assertEqual(r.returncode, 0, r.stderr)
        line = r.stdout.strip()
        self.assertIn("--skip-setup", line)
        self.assertIn(f"--commit {DEFAULT}", line)
        self.assertIn("--force-commit", line)

    def test_install_args_floating(self):
        r = _run(["install-args"], env={"LUFFY_HERMES_COMMIT": "latest"})
        self.assertEqual(r.stdout.strip(), "--skip-setup")
        self.assertNotIn("--commit", r.stdout)

    def test_matches_prefix(self):
        r = _run(["matches", DEFAULT])
        self.assertEqual(r.returncode, 0)
        r = _run(["matches", DEFAULT[:8]])
        self.assertEqual(r.returncode, 0)
        r = _run(["matches", "deadbeef"])
        self.assertEqual(r.returncode, 1)

    def test_matches_floating_always(self):
        r = _run(["matches", "anything"], env={"LUFFY_HERMES_COMMIT": "latest"})
        self.assertEqual(r.returncode, 0)
        r = _run(["matches", ""], env={"LUFFY_HERMES_COMMIT": "latest"})
        self.assertEqual(r.returncode, 0)

    def test_cache_suffix(self):
        r = _run(["cache-suffix"])
        self.assertEqual(r.stdout.strip(), DEFAULT[:12])
        r = _run(["cache-suffix"], env={"LUFFY_HERMES_COMMIT": "main"})
        self.assertEqual(r.stdout.strip(), "latest")


if __name__ == "__main__":
    unittest.main()
