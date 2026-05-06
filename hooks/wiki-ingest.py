#!/usr/bin/env python3
# ═══════════════════════════════════════════════════════════════
# LLM Wiki Auto-Ingest — NexaLance v4.5
# Converts Claude Code session JSONL transcripts → markdown
# and drops them into docs/wiki/raw/discussions/.
#
# Designed to be FULLY AUTOMATIC:
#   - Triggered by SessionStart and SessionEnd hooks
#   - Idempotent (manifest tracks processed sessions)
#   - Fast (skips already-ingested sessions instantly)
#   - Silent (no stdout noise; logs to docs/wiki/.ingest.log)
#   - Resilient (errors never break Claude Code; always exits 0)
#   - Privacy-aware (basic secret redaction; raw discussions
#     are git-ignored by default)
#
# Hook events: SessionStart, SessionEnd
# Working directory: project root (Claude Code's $PWD)
# ═══════════════════════════════════════════════════════════════
"""
What this script does:

1.  Read the project's PWD from $CLAUDE_PROJECT_DIR or current cwd.
2.  Map PWD → ~/.claude/projects/<encoded-cwd>/
3.  Find all *.jsonl session files there.
4.  Compare against docs/wiki/.ingest-manifest.json — skip already
    processed sessions.
5.  For each new session: parse JSONL, extract user/assistant text
    turns (skipping internal thinking/tool blocks), redact obvious
    secrets, write markdown to docs/wiki/raw/discussions/.
6.  Append to docs/wiki/log.md.
7.  Touch docs/wiki/.synthesis-pending so the playbook knows to
    synthesize on next user query.
8.  Exit 0 (always — failures must not block Claude Code).
"""
import json
import os
import re
import sys
from datetime import datetime
from pathlib import Path
from typing import Optional

# ─── Constants ───────────────────────────────────────────────
WIKI_DIR_NAME = "docs/wiki"
DISCUSSIONS_SUBDIR = "raw/discussions"
MANIFEST_FILE = ".ingest-manifest.json"
LOG_FILE = "log.md"
SYNTHESIS_FLAG = ".synthesis-pending"
INGEST_LOG = ".ingest.log"
CLAUDE_PROJECTS = Path.home() / ".claude" / "projects"

# Max length per message to write (avoid mega-files); the synthesis
# pass condenses these anyway. 50K chars per turn is plenty.
MAX_TURN_CHARS = 50_000


# ─── Helpers ─────────────────────────────────────────────────
def silent_log(wiki_dir: Path, msg: str) -> None:
    """Append to ingest log file. Never raises."""
    try:
        log_path = wiki_dir / INGEST_LOG
        log_path.parent.mkdir(parents=True, exist_ok=True)
        with log_path.open("a", encoding="utf-8") as f:
            ts = datetime.now().strftime("%Y-%m-%d %H:%M:%S")
            f.write(f"[{ts}] {msg}\n")
    except Exception:
        pass  # never fail


def encode_cwd_for_claude(cwd: str) -> str:
    """Claude Code encodes the cwd path for its session storage by
    replacing every character that isn't alphanumeric/dot/underscore
    with a hyphen. Examples:
      /Users/mac/projects/foo            → -Users-mac-projects-foo
      /Users/mac/Desktop/My Stuff/x      → -Users-mac-Desktop-My-Stuff-x
    """
    return re.sub(r"[^A-Za-z0-9._]", "-", cwd)


def _cwd_in_jsonl(jsonl_path: Path, abs_cwd: str, max_lines: int = 50) -> bool:
    """Scan up to `max_lines` of a JSONL to find ANY entry whose `cwd`
    field matches the target. Most entries don't have `cwd`, so we
    have to keep scanning until we either find a `cwd` or give up.
    """
    try:
        with jsonl_path.open(encoding="utf-8") as f:
            for i, line in enumerate(f):
                if i >= max_lines:
                    break
                try:
                    d = json.loads(line)
                except Exception:
                    continue
                cwd = d.get("cwd")
                if cwd is not None:
                    return cwd == abs_cwd
    except Exception:
        return False
    return False


def find_session_dir(project_cwd: Path) -> Optional[Path]:
    """Find ~/.claude/projects/<encoded>/ that matches this project.

    Strategy:
      1. Try the deterministic encoding first (fast path).
      2. If it doesn't exist, scan all subdirs and verify by inspecting
         each JSONL's `cwd` field (resilient to encoding-rule drift).
    """
    if not CLAUDE_PROJECTS.exists():
        return None
    abs_cwd = str(project_cwd.resolve())

    # Fast path
    candidate = CLAUDE_PROJECTS / encode_cwd_for_claude(abs_cwd)
    if candidate.exists() and any(candidate.glob("*.jsonl")):
        return candidate

    # Defensive scan
    for sub in sorted(CLAUDE_PROJECTS.iterdir()):
        if not sub.is_dir():
            continue
        try:
            jsonls = list(sub.glob("*.jsonl"))
            if not jsonls:
                continue
            # Check just the first JSONL's first 50 lines — fast.
            if _cwd_in_jsonl(jsonls[0], abs_cwd):
                return sub
        except Exception:
            continue
    return None


# ─── Redaction patterns (basic, defensive) ────────────────────
SECRET_PATTERNS = [
    # OpenAI / Anthropic / GitHub keys
    (re.compile(r"\b(sk-[A-Za-z0-9_\-]{20,})\b"), "sk-***REDACTED***"),
    (re.compile(r"\b(pk_(?:test|live)_[A-Za-z0-9]{20,})\b"), "pk_***REDACTED***"),
    (re.compile(r"\b(ghp_[A-Za-z0-9]{30,})\b"), "ghp_***REDACTED***"),
    (re.compile(r"\b(github_pat_[A-Za-z0-9_]{50,})\b"), "github_pat_***REDACTED***"),
    (re.compile(r"\b(gho_[A-Za-z0-9]{30,})\b"), "gho_***REDACTED***"),
    # Generic Bearer tokens
    (re.compile(r"\b(Bearer\s+[A-Za-z0-9._\-]{20,})\b"), "Bearer ***REDACTED***"),
    # AWS-style keys (AKIA...)
    (re.compile(r"\b(AKIA[A-Z0-9]{16})\b"), "AKIA***REDACTED***"),
    # Anthropic API keys
    (re.compile(r"\b(sk-ant-[A-Za-z0-9_\-]{30,})\b"), "sk-ant-***REDACTED***"),
    # Common .env-style password lines
    (re.compile(r"(PASSWORD|SECRET|TOKEN|API_KEY)\s*=\s*['\"]?([^\s'\"]{6,})", re.IGNORECASE),
     r"\1=***REDACTED***"),
]


def redact(text: str) -> str:
    """Apply basic secret redaction. Defensive layer — gitignore is primary."""
    if not isinstance(text, str):
        return text
    for pat, repl in SECRET_PATTERNS:
        text = pat.sub(repl, text)
    return text


# ─── JSONL → markdown conversion ──────────────────────────────
def extract_text_from_content(content) -> str:
    """Extract user-facing text from a message's content field.
    Skips tool_use, tool_result, thinking — those are internal noise.
    """
    if isinstance(content, str):
        return content
    if isinstance(content, list):
        parts = []
        for item in content:
            if not isinstance(item, dict):
                continue
            if item.get("type") == "text":
                txt = item.get("text", "")
                if txt:
                    parts.append(txt)
            # Optionally surface tool_result for important context, but
            # most are file reads/bash output — too noisy. Skip.
        return "\n\n".join(parts)
    return ""


def parse_session(jsonl_path: Path) -> Optional[dict]:
    """Parse a session JSONL into a structured dict.
    Returns None on parse failure (don't fail the hook).
    """
    try:
        meta = {
            "session_id": jsonl_path.stem,
            "first_ts": None,
            "last_ts": None,
            "cwd": None,
            "git_branch": None,
            "version": None,
            "turns": [],  # list of {role, ts, text}
        }
        with jsonl_path.open(encoding="utf-8") as f:
            for line in f:
                try:
                    d = json.loads(line)
                except Exception:
                    continue

                t = d.get("type")
                ts = d.get("timestamp")
                if ts and not meta["first_ts"]:
                    meta["first_ts"] = ts
                if ts:
                    meta["last_ts"] = ts
                if d.get("cwd") and not meta["cwd"]:
                    meta["cwd"] = d.get("cwd")
                if d.get("gitBranch") and not meta["git_branch"]:
                    meta["git_branch"] = d.get("gitBranch")
                if d.get("version") and not meta["version"]:
                    meta["version"] = d.get("version")

                if t in ("user", "assistant"):
                    msg = d.get("message", {})
                    if not isinstance(msg, dict):
                        continue
                    text = extract_text_from_content(msg.get("content", ""))
                    if not text or len(text.strip()) < 2:
                        continue
                    if len(text) > MAX_TURN_CHARS:
                        text = text[:MAX_TURN_CHARS] + "\n\n…(truncated)"
                    meta["turns"].append({
                        "role": t,
                        "ts": ts,
                        "text": redact(text),
                    })
        return meta if meta["turns"] else None
    except Exception:
        return None


def render_markdown(meta: dict, jsonl_path: Path) -> str:
    """Render parsed session as markdown."""
    sid = meta["session_id"]
    short = sid[:8]
    first_ts = meta.get("first_ts", "")
    date = first_ts[:10] if first_ts else datetime.now().strftime("%Y-%m-%d")

    lines = []
    lines.append(f"# Session — {date} — {short}")
    lines.append("")
    lines.append(f"- **Session ID:** `{sid}`")
    lines.append(f"- **Date:** {first_ts or 'unknown'} → {meta.get('last_ts') or 'unknown'}")
    if meta.get("cwd"):
        lines.append(f"- **Project path:** `{meta['cwd']}`")
    if meta.get("git_branch"):
        lines.append(f"- **Git branch:** `{meta['git_branch']}`")
    if meta.get("version"):
        lines.append(f"- **Claude Code version:** `{meta['version']}`")
    lines.append(f"- **Source:** `{jsonl_path}`")
    lines.append(f"- **Turns:** {len(meta['turns'])}")
    lines.append("")
    lines.append("---")
    lines.append("")

    for turn in meta["turns"]:
        role = "User" if turn["role"] == "user" else "Assistant"
        ts = turn.get("ts", "")
        ts_short = ts[11:19] if ts and len(ts) > 19 else ""
        header = f"## {role}" + (f" — {ts_short}" if ts_short else "")
        lines.append(header)
        lines.append("")
        lines.append(turn["text"])
        lines.append("")

    return "\n".join(lines)


# ─── Main ────────────────────────────────────────────────────
def main() -> int:
    project_dir = Path(os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()).resolve()
    wiki_dir = project_dir / WIKI_DIR_NAME

    # Skip silently if wiki not scaffolded (e.g. project doesn't use wiki)
    if not wiki_dir.exists():
        return 0

    discussions_dir = wiki_dir / DISCUSSIONS_SUBDIR
    discussions_dir.mkdir(parents=True, exist_ok=True)
    manifest_path = wiki_dir / MANIFEST_FILE
    log_path = wiki_dir / LOG_FILE
    flag_path = wiki_dir / SYNTHESIS_FLAG

    # Load manifest
    manifest = {"processed": []}
    if manifest_path.exists():
        try:
            manifest = json.loads(manifest_path.read_text(encoding="utf-8"))
        except Exception:
            silent_log(wiki_dir, "manifest read failed; resetting")
            manifest = {"processed": []}
    processed = set(manifest.get("processed", []))

    # Find session JSONL directory
    session_dir = find_session_dir(project_dir)
    if session_dir is None:
        silent_log(wiki_dir, f"no Claude Code sessions found for {project_dir}")
        return 0

    jsonls = sorted(session_dir.glob("*.jsonl"))
    if not jsonls:
        silent_log(wiki_dir, f"no JSONL files in {session_dir}")
        return 0

    new_sessions = []
    for jsonl in jsonls:
        sid = jsonl.stem
        if sid in processed:
            continue

        # Skip the CURRENT session (it's mid-write; ingest on next start)
        # Heuristic: if file modified within last 60 seconds, skip
        try:
            mtime = jsonl.stat().st_mtime
            if (datetime.now().timestamp() - mtime) < 60:
                continue
        except Exception:
            pass

        meta = parse_session(jsonl)
        if not meta or not meta["turns"]:
            silent_log(wiki_dir, f"skip empty/unparseable: {jsonl.name}")
            processed.add(sid)
            continue

        date = (meta.get("first_ts") or "")[:10] or datetime.now().strftime("%Y-%m-%d")
        out_name = f"{date}-{sid[:8]}.md"
        out_path = discussions_dir / out_name

        try:
            out_path.write_text(render_markdown(meta, jsonl), encoding="utf-8")
            processed.add(sid)
            new_sessions.append({
                "session_id": sid,
                "file": out_name,
                "turns": len(meta["turns"]),
                "date": date,
            })
            silent_log(wiki_dir, f"ingested {sid[:8]} ({len(meta['turns'])} turns) → {out_name}")
        except Exception as e:
            silent_log(wiki_dir, f"write failed for {sid[:8]}: {e}")

    # Persist manifest
    try:
        manifest["processed"] = sorted(processed)
        manifest["last_run"] = datetime.now().isoformat()
        manifest_path.write_text(json.dumps(manifest, indent=2), encoding="utf-8")
    except Exception:
        pass

    if new_sessions:
        # Update log.md
        try:
            with log_path.open("a", encoding="utf-8") as f:
                ts = datetime.now().strftime("%Y-%m-%d %H:%M")
                for s in new_sessions:
                    f.write(f"## [{ts}] ingest | session {s['session_id'][:8]} | {s['turns']} turns | {s['file']}\n")
        except Exception:
            pass

        # Touch synthesis flag — playbook reads this to decide whether
        # to do a synthesis pass at convenient moments.
        try:
            flag_path.write_text(
                json.dumps({
                    "pending": [s["file"] for s in new_sessions],
                    "queued_at": datetime.now().isoformat(),
                }, indent=2),
                encoding="utf-8",
            )
        except Exception:
            pass

        silent_log(wiki_dir, f"queued {len(new_sessions)} session(s) for synthesis")

    return 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except Exception as e:
        # Last-resort: never break Claude Code
        try:
            wd = Path(os.environ.get("CLAUDE_PROJECT_DIR") or os.getcwd()) / WIKI_DIR_NAME
            silent_log(wd, f"fatal: {e}")
        except Exception:
            pass
        sys.exit(0)
