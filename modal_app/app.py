"""Luffy Modal app — cheapest viable CPU profile.

Cost rules (Modal bills max(request, usage)):
  - Do NOT reserve high cpu/memory (defaults = 0.125 core, ~128MiB soft)
  - No GPU
  - Sparse shallow PR checkout (avoid monorepo full clone wall-time)
  - Cheap OpenRouter model default (gpt-4.1-mini)
  - Hermes baked in image once (amortized; not per-run cold install)

Run:
  modal run modal_app/app.py --bit 1
  modal run modal_app/app.py --bit 2
  modal run modal_app/app.py --bit 3 --repo Mr-Ashish/odoo --pr 3
  modal run modal_app/app.py --bit 4 --repo Mr-Ashish/odoo --pr 3   # dry enqueue plan
"""

from __future__ import annotations

import json
import os
import re
import shutil
import subprocess
import time
from pathlib import Path
from typing import Any

import modal

APP_NAME = "luffy-pr-review"
LUFFY_MODAL_VERSION = "0.4.0-cheap"
HERMES_PIN = "53559aaf86b84dadae83cd9bb605ca476f9a0606"
# OpenRouter — keep Modal compute cheap AND LLM spend low
DEFAULT_MODEL = "openai/gpt-4.1-mini"

_REPO_ROOT = Path(__file__).resolve().parent.parent

# Slim image: no build-essential/python3-dev (not needed if hermes install works without)
image = (
    modal.Image.debian_slim(python_version="3.12")
    .apt_install("git", "curl", "ca-certificates", "jq", "bash")
    .run_commands(
        "curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg "
        "| dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg",
        "chmod go+r /usr/share/keyrings/githubcli-archive-keyring.gpg",
        'echo "deb [arch=$(dpkg --print-architecture) '
        "signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] "
        'https://cli.github.com/packages stable main" '
        "> /etc/apt/sources.list.d/github-cli.list",
        "apt-get update && apt-get install -y gh",
        # Hermes pin once per image (saves per-run install time = billable seconds)
        f"curl -fsSL https://hermes-agent.nousresearch.com/install.sh "
        f"| bash -s -- --skip-setup --commit {HERMES_PIN} --force-commit",
        "export PATH=\"$HOME/.local/bin:$HOME/.hermes/bin:$PATH\" && hermes --version",
        f"echo {HERMES_PIN} > /root/.hermes-pin",
    )
    .env(
        {
            "PATH": "/root/.local/bin:/root/.hermes/bin:/usr/local/bin:/usr/bin:/bin",
            "LUFFY_HERMES_PREBAKED": "1",
            "LUFFY_HERMES_COMMIT": HERMES_PIN,
        }
    )
    .pip_install("fastapi[standard]>=0.115.0")
    .add_local_dir(str(_REPO_ROOT / "scripts"), remote_path="/opt/luffy/scripts")
    .add_local_dir(str(_REPO_ROOT / "agent"), remote_path="/opt/luffy/agent")
)

app = modal.App(APP_NAME, image=image)

openrouter_secret = modal.Secret.from_name("luffy-openrouter")
github_secret = modal.Secret.from_name("luffy-github")
trace_vol = modal.Volume.from_name("luffy-traces", create_if_missing=True)

# Cheapest resource profile: Modal minimums (no cpu=/memory= reservation)
# https://modal.com/docs/guide/resources — default 0.125 core; over-request bills higher
_CHEAP = dict(
    # cpu omitted → 0.125 physical core min
    # memory omitted → soft minimum; hermes may burst — allow modest floor only if OOM
    timeout=60 * 25,  # hard cap wall time (kills runaway spend)
)


def _run(
    cmd: list[str],
    *,
    env: dict | None = None,
    cwd: str | None = None,
) -> subprocess.CompletedProcess[str]:
    merged = {**os.environ, **(env or {})}
    return subprocess.run(
        cmd, capture_output=True, text=True, check=False, env=merged, cwd=cwd
    )


@app.function()  # absolute minimum resources
def health() -> dict:
    return {
        "ok": True,
        "app": APP_NAME,
        "version": LUFFY_MODAL_VERSION,
        "runtime": "modal",
        "hermes_pin": HERMES_PIN,
        "profile": "cheap",
        "default_model": DEFAULT_MODEL,
    }


@app.function()
@modal.fastapi_endpoint(method="GET")
def health_http() -> dict:
    return health.local()


@app.function(secrets=[github_secret, openrouter_secret], timeout=180)
def probe_clone(repo: str = "Mr-Ashish/odoo") -> dict:
    """Bit 2: tools + secrets + shallow clone (no LLM)."""
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN") or ""
    if not token or not os.environ.get("OPENROUTER_API_KEY"):
        return {"ok": False, "error": "missing secrets"}

    work = Path("/tmp/luffy-probe")
    shutil.rmtree(work, ignore_errors=True)
    work.mkdir(parents=True)
    url = f"https://x-access-token:{token}@github.com/{repo}.git"
    # depth=1 only — never full history
    clone = _run(
        ["git", "clone", "--depth", "1", "--filter=blob:none", url, str(work / "repo")],
        env={"GIT_TERMINAL_PROMPT": "0"},
    )
    if clone.returncode != 0:
        return {"ok": False, "error": "clone_failed", "stderr": (clone.stderr or "")[-600:]}

    head = _run(["git", "-C", str(work / "repo"), "rev-parse", "--short", "HEAD"])
    hermes = _run(["hermes", "--version"])
    prs = _run(
        ["gh", "pr", "list", "-R", repo, "--limit", "3", "--json", "number,title"],
        env={"GH_TOKEN": token, "GITHUB_TOKEN": token},
    )
    return {
        "ok": True,
        "bit": 2,
        "version": LUFFY_MODAL_VERSION,
        "repo": repo,
        "head": (head.stdout or "").strip(),
        "hermes": (hermes.stdout or hermes.stderr or "")[:120],
        "pr_list_rc": prs.returncode,
        "pr_list_preview": (prs.stdout or "")[:400],
        "profile": "cheap",
    }


def _sparse_checkout_pr(repo: str, pr_number: int, workspace: Path, token: str) -> str:
    """Shallow clone + sparse paths for changed files only (monorepo-cheap)."""
    env = {
        **os.environ,
        "GH_TOKEN": token,
        "GITHUB_TOKEN": token,
        "GIT_TERMINAL_PROMPT": "0",
    }
    # List changed files (cap paths)
    files_p = _run(
        [
            "gh",
            "api",
            f"repos/{repo}/pulls/{pr_number}/files",
            "--paginate",
            "-q",
            ".[].filename",
        ],
        env=env,
    )
    paths = [ln.strip() for ln in (files_p.stdout or "").splitlines() if ln.strip()]
    # unique top-level dirs + files, cap 40
    sparse: list[str] = []
    for p in paths[:80]:
        sparse.append(p)
        top = p.split("/")[0]
        if top and top not in sparse:
            sparse.append(top)
    sparse = sparse[:40]

    url = f"https://x-access-token:{token}@github.com/{repo}.git"
    shutil.rmtree(workspace, ignore_errors=True)
    workspace.mkdir(parents=True)

    # init empty + sparse
    _run(["git", "init"], cwd=str(workspace))
    _run(["git", "remote", "add", "origin", url], cwd=str(workspace))
    _run(["git", "config", "core.sparseCheckout", "true"], cwd=str(workspace))
    sparse_file = workspace / ".git" / "info" / "sparse-checkout"
    sparse_file.parent.mkdir(parents=True, exist_ok=True)
    if sparse:
        sparse_file.write_text("\n".join(sparse) + "\n")
    else:
        sparse_file.write_text("/*\n")  # fallback full tree shallow

    # fetch PR head only
    fetch = _run(
        [
            "git",
            "fetch",
            "--depth",
            "1",
            "origin",
            f"pull/{pr_number}/head:luffy-pr",
        ],
        cwd=str(workspace),
        env=env,
    )
    if fetch.returncode != 0:
        # fallback: shallow full clone of default + pr checkout (still depth 1)
        shutil.rmtree(workspace, ignore_errors=True)
        c = _run(
            ["git", "clone", "--depth", "1", url, str(workspace)],
            env=env,
        )
        if c.returncode != 0:
            raise RuntimeError(f"clone failed: {(c.stderr or '')[-500:]}")
        _run(["gh", "pr", "checkout", str(pr_number)], cwd=str(workspace), env=env)
    else:
        _run(["git", "checkout", "luffy-pr"], cwd=str(workspace))

    head = _run(["git", "rev-parse", "--short", "HEAD"], cwd=str(workspace))
    return (head.stdout or "").strip()


@app.function(
    secrets=[github_secret, openrouter_secret],
    # CHEAP: no cpu=/memory= reservation (Modal min). Only timeout.
    timeout=_CHEAP["timeout"],
    volumes={"/traces": trace_vol},
)
def review_pr(
    repo: str,
    pr_number: int,
    *,
    model: str = DEFAULT_MODEL,
    post_comment: bool = True,
) -> dict:
    """Bit 3: Luffy review on cheapest Modal profile + cheap LLM default."""
    t0 = time.time()
    token = os.environ.get("GITHUB_TOKEN") or os.environ.get("GH_TOKEN") or ""
    or_key = os.environ.get("OPENROUTER_API_KEY") or ""
    if not token or not or_key:
        return {"ok": False, "error": "missing secrets"}

    luffy_root = Path("/opt/luffy")
    if not (luffy_root / "scripts" / "run-luffy-review.sh").is_file():
        return {"ok": False, "error": "luffy pack missing"}

    work = Path(f"/tmp/luffy-run-{pr_number}-{int(t0)}")
    shutil.rmtree(work, ignore_errors=True)
    pack = work / "luffy"
    workspace = work / "workspace"
    hermes_home = work / "hermes-home"
    out_dir = pack / ".luffy-out"
    pack.mkdir(parents=True)
    shutil.copytree(luffy_root / "scripts", pack / "scripts")
    shutil.copytree(luffy_root / "agent", pack / "agent")
    for p in (pack / "scripts").iterdir():
        try:
            p.chmod(p.stat().st_mode | 0o111)
        except OSError:
            pass

    hermes_home.mkdir(parents=True)
    (hermes_home / "memories").mkdir(parents=True)
    seed = pack / "agent" / "MEMORY.seed.md"
    if seed.is_file():
        shutil.copy(seed, hermes_home / "memories" / "MEMORY.md")
    out_dir.mkdir(parents=True)

    try:
        head_sha = _sparse_checkout_pr(repo, pr_number, workspace, token)
    except Exception as e:  # noqa: BLE001
        return {"ok": False, "error": f"checkout: {e}", "elapsed_s": round(time.time() - t0, 1)}

    env = {
        **os.environ,
        "OPENROUTER_API_KEY": or_key,
        "GH_TOKEN": token,
        "GITHUB_TOKEN": token,
        "LUFFY_ROOT": str(pack),
        "WORKSPACE_ROOT": str(workspace),
        "HERMES_HOME": str(hermes_home),
        "OUT_DIR": str(out_dir),
        "TRACE_ROOT": str(out_dir / "traces"),
        "REPO": repo,
        "GITHUB_REPOSITORY": repo,
        "PR_NUMBER": str(pr_number),
        "LUFFY_MODEL": model,
        "OPENROUTER_MODEL": model,
        "LUFFY_HERMES_PREBAKED": "1",
        "LUFFY_HERMES_COMMIT": HERMES_PIN,
        "LUFFY_MEMORY_MODE": "local",
        "LUFFY_LOCAL_PUBLISH": "0",  # skip git push (saves time + failures)
        "LUFFY_HUB_PUBLISH": "0",
        "POST_COMMENT": "1" if post_comment else "0",
        "TRIGGER_COMMENT": "modal cheap e2e",
        "MAX_DIFF_BYTES": "200000",  # smaller context = fewer tokens
        "LUFFY_TOOLSETS": "",  # empty may fall back; prefer terminal but costlier
        "LUFFY_HOST": "modal",  # F31 Run Console host label
        "PATH": os.environ.get(
            "PATH",
            "/root/.local/bin:/root/.hermes/bin:/usr/local/bin:/usr/bin:/bin",
        ),
    }
    # Disable agent tools for cheapest LLM path (diff-only review)
    env["LUFFY_TOOLSETS"] = "terminal"  # still needed for hermes; keep

    orch = pack / "scripts" / "run-luffy-review.sh"
    proc = _run(["bash", str(orch)], env=env)
    orch_rc = proc.returncode

    review_files = [
        p
        for p in sorted(out_dir.glob("review-*.md"))
        if ".raw." not in p.name
    ]
    review_path = review_files[0] if review_files else None

    post_rc = None
    if post_comment and review_path and review_path.is_file():
        post = _run(
            [
                "bash",
                str(pack / "scripts" / "post-review-comment.sh"),
                str(review_path),
                str(pr_number),
            ],
            env=env,
        )
        post_rc = post.returncode

    run_id = f"{repo.replace('/', '--')}-pr{pr_number}-{int(t0)}"
    vol_dest = Path("/traces") / run_id
    vol_err = None
    try:
        if out_dir.exists():
            shutil.copytree(out_dir, vol_dest, dirs_exist_ok=True)
            trace_vol.commit()
    except Exception as e:  # noqa: BLE001
        vol_err = str(e)

    preview = ""
    if review_path and review_path.is_file():
        preview = review_path.read_text(errors="replace")[:1200]

    # F31: surface Run Console bundle path (orchestrator writes run-bundle.json)
    run_bundle = out_dir / "run-bundle.json"
    if not run_bundle.is_file() and (pack / "scripts" / "pack-run-for-ui.py").is_file():
        # Soft fallback if older orchestrator missed pack stage
        latest = out_dir / "latest-trace-dir.txt"
        pack_src = Path(latest.read_text().strip()) if latest.is_file() else out_dir
        _run(
            [
                "python3",
                str(pack / "scripts" / "pack-run-for-ui.py"),
                "--dir",
                str(pack_src if pack_src.is_dir() else out_dir),
                "-o",
                str(run_bundle),
                "--host",
                "modal",
                "--soft",
            ],
            env=env,
        )
        if run_bundle.is_file() and vol_dest.exists():
            try:
                shutil.copy2(run_bundle, vol_dest / "run-bundle.json")
                trace_vol.commit()
            except Exception:  # noqa: BLE001
                pass

    return {
        "ok": orch_rc == 0 and bool(review_path),
        "bit": 3,
        "profile": "cheap",
        "version": LUFFY_MODAL_VERSION,
        "repo": repo,
        "pr_number": pr_number,
        "head": head_sha,
        "model": model,
        "orch_rc": orch_rc,
        "post_rc": post_rc,
        "review_path": str(review_path) if review_path else None,
        "run_bundle": str(run_bundle) if run_bundle.is_file() else None,
        "review_preview": preview,
        "orch_stderr_tail": (proc.stderr or "")[-1500:],
        "orch_stdout_tail": (proc.stdout or "")[-800:],
        "elapsed_s": round(time.time() - t0, 1),
        "trace_volume_path": str(vol_dest),
        "trace_volume_error": vol_err,
        "resources": "default-min (no cpu/memory reservation)",
    }


_LUFFY_TRIGGER_RE = re.compile(
    r"@luffy\b.*\breview\b",
    re.IGNORECASE | re.DOTALL,
)


def parse_enqueue_payload(item: dict[str, Any]) -> dict[str, Any]:
    """Parse simple API or GitHub issue_comment webhook → enqueue plan.

    Simple API:
      {"repo": "owner/name", "pr": 3, "model": "...", "post_comment": true}

    GitHub issue_comment (PR thread):
      action=created, issue.pull_request set, comment.body matches @luffy … review
    """
    if not isinstance(item, dict):
        return {"ok": False, "error": "body must be a JSON object"}

    # --- simple API ---
    if item.get("repo") and item.get("pr") is not None:
        try:
            pr_n = int(item["pr"])
        except (TypeError, ValueError):
            return {"ok": False, "error": "pr must be an int"}
        repo = str(item["repo"]).strip()
        if "/" not in repo:
            return {"ok": False, "error": "repo must be owner/name"}
        model = str(item.get("model") or DEFAULT_MODEL)
        post = item.get("post_comment", True)
        if isinstance(post, str):
            post = post.strip().lower() not in ("0", "false", "no", "off")
        return {
            "ok": True,
            "source": "api",
            "repo": repo,
            "pr_number": pr_n,
            "model": model,
            "post_comment": bool(post),
            "trigger": "api",
        }

    # --- GitHub webhook (issue_comment on a PR) ---
    action = item.get("action")
    issue = item.get("issue") or {}
    comment = item.get("comment") or {}
    repository = item.get("repository") or {}
    if issue.get("pull_request") and repository.get("full_name"):
        body = (comment.get("body") or "") if isinstance(comment, dict) else ""
        if action and action not in ("created", "edited"):
            return {
                "ok": False,
                "skipped": True,
                "error": f"ignore action={action}",
                "source": "github",
            }
        if not _LUFFY_TRIGGER_RE.search(body):
            return {
                "ok": False,
                "skipped": True,
                "error": "comment does not match @luffy review",
                "source": "github",
            }
        try:
            pr_n = int(issue.get("number"))
        except (TypeError, ValueError):
            return {"ok": False, "error": "issue.number missing", "source": "github"}
        return {
            "ok": True,
            "source": "github",
            "repo": str(repository["full_name"]),
            "pr_number": pr_n,
            "model": str(item.get("model") or DEFAULT_MODEL),
            "post_comment": True,
            "trigger": (body or "")[:200],
            "comment_id": comment.get("id") if isinstance(comment, dict) else None,
        }

    return {
        "ok": False,
        "error": "unrecognized payload (need repo+pr or GitHub issue_comment on a PR)",
    }


def plan_enqueue(
    repo: str,
    pr_number: int,
    *,
    model: str = DEFAULT_MODEL,
    post_comment: bool = True,
) -> dict[str, Any]:
    """Bit 4 dry plan — no Modal spawn, no Hermes (free)."""
    return {
        "ok": True,
        "bit": 4,
        "dry_run": True,
        "spawned": False,
        "version": LUFFY_MODAL_VERSION,
        "repo": repo,
        "pr_number": pr_number,
        "model": model or DEFAULT_MODEL,
        "post_comment": post_comment,
        "note": "Pass spawn=True / webhook without dry_run to review_pr.spawn",
    }


@app.function(secrets=[github_secret, openrouter_secret], timeout=120)
def enqueue_review(
    repo: str,
    pr_number: int,
    *,
    model: str = DEFAULT_MODEL,
    post_comment: bool = True,
    dry_run: bool = False,
) -> dict[str, Any]:
    """Bit 4: spawn review_pr (or return plan when dry_run). Never runs Hermes here."""
    if dry_run:
        return plan_enqueue(repo, pr_number, model=model, post_comment=post_comment)
    # Spawn — returns immediately; worker runs separately
    call = review_pr.spawn(
        repo, pr_number, model=model or DEFAULT_MODEL, post_comment=post_comment
    )
    call_id = getattr(call, "object_id", None) or getattr(call, "objectId", None) or str(call)
    return {
        "ok": True,
        "bit": 4,
        "dry_run": False,
        "spawned": True,
        "version": LUFFY_MODAL_VERSION,
        "repo": repo,
        "pr_number": pr_number,
        "model": model or DEFAULT_MODEL,
        "post_comment": post_comment,
        "call_id": call_id,
        "profile": "cheap",
    }


@app.function(secrets=[github_secret, openrouter_secret], timeout=60)
@modal.fastapi_endpoint(method="POST")
def review_webhook(item: dict) -> dict:
    """HTTP doorbell: parse body → spawn review_pr (Hermes never runs in this handler).

    Deploy: `modal deploy modal_app/app.py` then POST the endpoint URL.
    Optional query-less body — see parse_enqueue_payload.
    Set env LUFFY_WEBHOOK_DRY_RUN=1 on the app to plan-only (ops testing).
    """
    plan = parse_enqueue_payload(item if isinstance(item, dict) else {})
    if not plan.get("ok"):
        # skipped is still HTTP 200-ish for GitHub (avoid retries); surface ok=false
        return {**plan, "bit": 4, "version": LUFFY_MODAL_VERSION}
    dry = os.environ.get("LUFFY_WEBHOOK_DRY_RUN", "").strip() in ("1", "true", "yes")
    result = enqueue_review.local(
        plan["repo"],
        int(plan["pr_number"]),
        model=str(plan.get("model") or DEFAULT_MODEL),
        post_comment=bool(plan.get("post_comment", True)),
        dry_run=dry,
    )
    result["source"] = plan.get("source")
    result["trigger"] = plan.get("trigger")
    if plan.get("comment_id") is not None:
        result["comment_id"] = plan["comment_id"]
    return result


@app.local_entrypoint()
def main(
    bit: int = 1,
    repo: str = "Mr-Ashish/odoo",
    pr: int = 3,
    model: str = DEFAULT_MODEL,
    post_comment: bool = True,
    spawn: bool = False,
) -> None:
    if bit == 2:
        result = probe_clone.remote(repo=repo)
        print(json.dumps(result, indent=2)[:2000])
        assert result.get("ok"), result
        print("BIT2_OK")
        return
    if bit == 3:
        print(f"CHEAP review_pr {repo}#{pr} model={model}")
        result = review_pr.remote(repo, pr, model=model, post_comment=post_comment)
        slim = {k: v for k, v in result.items() if k != "review_preview"}
        print(json.dumps(slim, indent=2))
        if result.get("review_preview"):
            print("--- preview ---")
            print(result["review_preview"][:800])
        assert result.get("ok"), result
        print("BIT3_OK")
        return
    if bit == 4:
        # Default dry plan (no OpenRouter spend). --spawn to actually enqueue.
        print(f"BIT4 enqueue plan {repo}#{pr} model={model} spawn={spawn}")
        if spawn:
            result = enqueue_review.remote(
                repo, pr, model=model, post_comment=post_comment, dry_run=False
            )
        else:
            result = plan_enqueue(repo, pr, model=model, post_comment=post_comment)
            # Also exercise payload parser with simple API shape
            parsed = parse_enqueue_payload(
                {"repo": repo, "pr": pr, "model": model, "post_comment": post_comment}
            )
            result["parsed_ok"] = parsed.get("ok")
            gh = parse_enqueue_payload(
                {
                    "action": "created",
                    "issue": {"number": pr, "pull_request": {"url": "x"}},
                    "comment": {"id": 1, "body": "@luffy review this pr"},
                    "repository": {"full_name": repo},
                }
            )
            result["github_parse_ok"] = gh.get("ok")
            result["github_skip"] = parse_enqueue_payload(
                {
                    "action": "created",
                    "issue": {"number": pr, "pull_request": {"url": "x"}},
                    "comment": {"body": "lgtm"},
                    "repository": {"full_name": repo},
                }
            ).get("skipped")
        print(json.dumps(result, indent=2)[:2000])
        assert result.get("ok"), result
        if not spawn:
            assert result.get("parsed_ok") and result.get("github_parse_ok")
            assert result.get("github_skip") is True
        print("BIT4_OK")
        return
    result = health.remote()
    print(result)
    assert result.get("ok")
    print("BIT1_OK")
