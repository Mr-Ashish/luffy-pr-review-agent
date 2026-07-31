"""F20: install-luffy.sh copies runtime pack into a target repo."""

from __future__ import annotations

import os
import subprocess
import tempfile
import unittest
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
SCRIPT = ROOT / "scripts" / "install-luffy.sh"


def _run(args: list[str], **kw) -> subprocess.CompletedProcess:
    return subprocess.run(
        ["bash", str(SCRIPT), *args],
        capture_output=True,
        text=True,
        cwd=str(ROOT),
        **kw,
    )


class InstallLuffyTests(unittest.TestCase):
    def test_help(self):
        r = _run(["--help"])
        self.assertEqual(r.returncode, 0)
        self.assertIn("copy the Luffy runtime pack", r.stdout + r.stderr)

    def test_missing_dest(self):
        r = _run([])
        self.assertEqual(r.returncode, 1)

    def test_refuse_self_without_force(self):
        r = _run(["--dest", str(ROOT)])
        self.assertEqual(r.returncode, 1)
        self.assertIn("refusing", r.stderr.lower())

    def test_dry_run_no_writes(self):
        with tempfile.TemporaryDirectory() as td:
            dest = Path(td)
            (dest / ".git").mkdir()  # look like a repo root
            r = _run(["--dest", str(dest), "--dry-run"])
            self.assertEqual(r.returncode, 0, r.stderr)
            self.assertIn("DRY", r.stderr)
            # no pack files written
            self.assertFalse((dest / "agent").exists())
            self.assertFalse((dest / "scripts" / "run-luffy-review.sh").exists())

    def test_install_runtime_pack(self):
        with tempfile.TemporaryDirectory() as td:
            dest = Path(td)
            r = _run(["--dest", str(dest), "--force"])
            self.assertEqual(r.returncode, 0, r.stderr)
            self.assertTrue((dest / "agent" / "SOUL.md").is_file())
            self.assertTrue((dest / "agent" / "config.yaml").is_file())
            self.assertTrue((dest / "scripts" / "run-luffy-review.sh").is_file())
            self.assertTrue((dest / "scripts" / "hermes-pin.sh").is_file())
            self.assertTrue((dest / "scripts" / "cooldown-check.sh").is_file())
            self.assertTrue((dest / "scripts" / "install-luffy.sh").is_file())
            self.assertTrue((dest / "scripts" / "usage-summary.py").is_file())
            self.assertTrue(
                (dest / ".github" / "workflows" / "luffy-pr-review.yml").is_file()
            )
            self.assertTrue((dest / ".luffy-install-stamp").is_file())
            # image build scripts not in default pack
            self.assertFalse((dest / "scripts" / "build-luffy-runner-image.sh").exists())
            self.assertFalse((dest / "docker").exists())
            # executable bit preserved on shell scripts
            self.assertTrue(os.access(dest / "scripts" / "run-luffy-review.sh", os.X_OK))

    def test_skip_existing_without_force(self):
        with tempfile.TemporaryDirectory() as td:
            dest = Path(td)
            r = _run(["--dest", str(dest), "--force"])
            self.assertEqual(r.returncode, 0, r.stderr)
            soul = dest / "agent" / "SOUL.md"
            original = soul.read_text()
            soul.write_text("MUTATED\n")
            r2 = _run(["--dest", str(dest)])  # no --force
            self.assertEqual(r2.returncode, 0, r2.stderr)
            self.assertIn("exists (skip", r2.stderr)
            self.assertEqual(soul.read_text(), "MUTATED\n")
            # force restores
            r3 = _run(["--dest", str(dest), "--force"])
            self.assertEqual(r3.returncode, 0, r3.stderr)
            self.assertEqual(soul.read_text(), original)

    def test_with_hub_ingest(self):
        with tempfile.TemporaryDirectory() as td:
            dest = Path(td)
            r = _run(["--dest", str(dest), "--force", "--with-hub-ingest"])
            self.assertEqual(r.returncode, 0, r.stderr)
            self.assertTrue(
                (dest / ".github" / "workflows" / "ingest-luffy-run.yml").is_file()
            )


if __name__ == "__main__":
    unittest.main()
