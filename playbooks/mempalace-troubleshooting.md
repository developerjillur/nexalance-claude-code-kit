# Playbook: MemPalace Troubleshooting

> **When Claude reads this:** the user reports MemPalace not working, OR `mempalace_status` returns errors, OR memory doesn't persist between sessions.
> **First action — always:** run `bash diagnose-mempalace.sh` from the project root. It identifies the exact failing layer in 12 checks. This playbook explains what each finding means and how to fix it.

---

## The most common root cause (~70% of cases)

**Symptom:** `claude mcp list` shows `mempalace: python -m mempalace.mcp_server - ✗ Failed to connect` even though `pip install mempalace` succeeded.

**Root cause:** The kit hardcoded `python` (the bare command) for the MCP server and hook commands. On many systems — pyenv users, modern macOS without legacy `python` symlink, Linux distros that never aliased `python → python3`, asdf users — the `python` command does not resolve, but `python3` does.

The errors are silenced (`2>/dev/null || true`) so it fails invisibly.

**Fix (recommended):** re-run `setup-nexalance.sh` from the v4.4 LITE+ kit (post Apr-26-2026). It auto-detects the working Python 3 interpreter and uses the absolute path everywhere.

**Manual fix:**
```bash
PY=$(command -v python3)
claude mcp remove mempalace --scope user
claude mcp add mempalace --scope user -- "$PY" -m mempalace.mcp_server

# Then patch ~/.claude/settings.json hook commands:
sed -i.bak "s|python -m mempalace|$PY -m mempalace|g" ~/.claude/settings.json
```

Restart Claude Code after.

---

## Symptom → Cause → Fix

### 1. "MCP shows 'Failed to connect' for mempalace"

| Possible cause | Diagnostic check | Fix |
|----------------|------------------|-----|
| `python` doesn't resolve to Python 3 | Run `python --version` — if pyenv error or "command not found", this is it | Re-run `setup-nexalance.sh` (auto-detects) OR manual fix above |
| mempalace not installed in the Python that MCP uses | `claude mcp list` shows the command; run that command's Python with `-c "import mempalace"` | `<PY> -m pip install --user mempalace` where `<PY>` is the interpreter from MCP config |
| Plugin install duplicate — both `plugin:mempalace:mempalace` AND `mempalace` registered | `claude mcp list` shows both | Remove the plugin: `claude plugin uninstall mempalace` (the explicit `claude mcp add` is the supported path) |
| MemPalace data dir permissions broken | `ls -la ~/.mempalace` or `~/mempalace-data` | `chmod -R u+w ~/.mempalace` |
| Stale MCP config pointing to a deleted Python (e.g. removed pyenv version) | `claude mcp list` shows full path that no longer exists | Re-register: `claude mcp remove mempalace --scope user && claude mcp add mempalace --scope user -- "$(command -v python3)" -m mempalace.mcp_server` |

### 2. "MCP shows 'Connected' but `mempalace_search` returns nothing"

| Possible cause | Diagnostic check | Fix |
|----------------|------------------|-----|
| `PROJECT_WING` is still the placeholder `"project-wing-name"` | `grep PROJECT_WING CLAUDE.md` | Re-run `setup-project-wing.sh "<real-wing>" "Project" "client" <tier>` |
| Wing was never seeded (init step failed silently in older kit versions) | Check 10 in `diagnose-mempalace.sh` — "Wing has 0 triples" | Manually seed: `python3 -c "from mempalace.knowledge_graph import KnowledgeGraph; kg=KnowledgeGraph(); kg.add_triple('YOUR_WING','is_project','Project Name')"` |
| Claude is searching without `--wing` filter | Check Claude's actual call — should always include `--wing PROJECT_WING` | Re-read `playbooks/persistent-memory.md` — wing isolation rules |
| Searching wrong wing (cross-project bleed) | `mempalace_search "x"` returns results from DIFFERENT project | Confirm `PROJECT_WING` in CLAUDE.md matches what was seeded |

### 3. "Memory doesn't persist between sessions"

| Possible cause | Diagnostic check | Fix |
|----------------|------------------|-----|
| Stop hook fails silently | `cat ~/.mempalace-hook.log` (added in v4.4 LITE+) — shows actual errors | Errors give a real signal now; act on them. Common: same `python` issue as #1. |
| Hook command points to wrong Python | `grep mempalace ~/.claude/settings.json` — check the command path | Re-run `setup-nexalance.sh` (rewrites with correct absolute path) |
| MemPalace MCP failed → tools never invoked → no save attempted | `claude mcp list` | Fix MCP first (symptom #1) |
| User pressed `/compact` without PreCompact hook firing | Same as Stop hook — check `~/.mempalace-hook.log` | Same fix |

### 4. "Memory is bleeding between projects"

| Cause | Fix |
|-------|-----|
| MemPalace called WITHOUT `--wing` filter | Hard rule from `playbooks/persistent-memory.md`: every call gets `--wing CURRENT_WING`. Audit recent calls in transcript. |
| Two projects share the same `PROJECT_WING` value | Check `CLAUDE.md` of both — they MUST differ. Rename one and re-init. |

### 5. "MemPalace MCP slow or stalls Claude Code startup"

| Cause | Fix |
|-------|-----|
| TaskMaster MCP in `.mcp.json` is unresponsive (npx hang) | Diagnose check 11. Either remove TaskMaster or pre-warm: `npx --yes task-master-ai --version` |
| Data dir is huge (multiple GB) | `du -sh ~/.mempalace` — if > 1GB, prune old wings: `mempalace wing prune --older-than 90d` |
| Network issue if pip is reinstalling on every start | Should NOT happen — verify `pip show mempalace` works offline |

### 6. "Hooks log file (`~/.mempalace-hook.log`) shows errors"

> v4.4 LITE+ logs hook failures here instead of swallowing them silently. This is by design — the log is your friend.

Tail it during a session:
```bash
tail -f ~/.mempalace-hook.log
```

Common entries and fixes:

| Log entry | Cause | Fix |
|-----------|-------|-----|
| `ModuleNotFoundError: No module named 'mempalace'` | Hook's Python doesn't have mempalace | The hook command got installed pointing to a different Python than where mempalace lives. Re-run `setup-nexalance.sh`. |
| `pyenv: python: command not found` | Bare `python` on a pyenv system | Re-run `setup-nexalance.sh` (rewrites to absolute python3 path) |
| `Permission denied: '~/.mempalace/...'` | Data dir not writable | `chmod -R u+w ~/.mempalace` |
| `sqlite3.OperationalError: database is locked` | Two MemPalace instances writing concurrently | Restart Claude Code; only one should run |

---

## Self-service diagnostic flow

```
1. bash diagnose-mempalace.sh
   ↓
2. Read the "ROOT CAUSES FOUND" section at the bottom
   ↓
3. Apply the fix it suggests
   ↓
4. Restart Claude Code (close + reopen)
   ↓
5. Re-run diagnose-mempalace.sh — confirm all checks pass
   ↓
6. In Claude Code, type: /mcp
   → mempalace should show "Connected"
```

If the diagnostic passes but the symptom persists, capture:
- Full output of `claude mcp list`
- Full output of `bash diagnose-mempalace.sh`
- Last 50 lines of `~/.mempalace-hook.log`
- Output of `python3 -c "import mempalace; print(mempalace.__version__)"`

That's enough to escalate / file a kit issue.

---

## Why these failures were so hard to find before v4.4 LITE+

The original `setup-nexalance.sh` had **21 instances** of `2>/dev/null` and `setup-project-wing.sh` had **9 more**. Hook commands all ended in `|| true`. So when something failed, you saw:

- `claude mcp list` — "Failed to connect" ❌ but no reason
- `~/.claude/settings.json` hooks — fired → failed → exited 0 → silence

The fixes:
1. Hooks now log to `~/.mempalace-hook.log` instead of `/dev/null`
2. MCP registration errors are visible (no longer `2>/dev/null`)
3. Wing init errors are visible (no longer `2>/dev/null || echo "skipped"`)
4. Interpreter is auto-detected, not assumed
5. Project-level `.mcp.json` no longer duplicates user-level (no more "Failed at project, OK at user" confusion)
6. Placeholder wing names are rejected at setup time

---

*Back to CLAUDE.md core. For MemPalace setup details, see `playbooks/persistent-memory.md`.*
