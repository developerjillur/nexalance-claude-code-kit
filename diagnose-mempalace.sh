#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# NexaLance — MemPalace Diagnostic v1.0
# Run from inside a project directory to find why MemPalace
# is misbehaving. Performs 12 checks across all layers.
# Usage: bash diagnose-mempalace.sh
# ═══════════════════════════════════════════════════════════════

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
DIM='\033[2m'
NC='\033[0m'

pass()  { echo -e "${GREEN}✅ PASS${NC}: $1"; PASS=$((PASS+1)); }
warn()  { echo -e "${YELLOW}⚠️  WARN${NC}: $1"; WARN=$((WARN+1)); }
fail()  { echo -e "${RED}❌ FAIL${NC}: $1"; FAIL=$((FAIL+1)); }
info()  { echo -e "${BLUE}ℹ️  INFO${NC}: $1"; }
note()  { echo -e "   ${DIM}$1${NC}"; }

PASS=0; WARN=0; FAIL=0
ROOT_CAUSES=()

echo "═══════════════════════════════════════════════════════════"
echo "🔍 MemPalace Diagnostic — checking 12 layers"
echo "   Project: $(basename "$PWD")"
echo "   Date:    $(date '+%Y-%m-%d %H:%M:%S')"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ─── Check 1: Python interpreter resolution ───────────────────
echo "── [1/12] Python interpreter resolution ──"

PY_BIN=""
for cand in python3 python; do
    if command -v "$cand" >/dev/null 2>&1; then
        if "$cand" -c 'import sys; sys.exit(0 if sys.version_info[0]>=3 else 1)' 2>/dev/null; then
            PY_BIN="$cand"
            note "$cand → $(command -v "$cand")  [$($cand --version 2>&1)]"
            break
        else
            warn "$cand exists but is Python 2.x or fails to run"
        fi
    fi
done

if [ -z "$PY_BIN" ]; then
    fail "No working Python 3.x interpreter found"
    ROOT_CAUSES+=("Install Python 3.10+ (e.g. brew install python3 OR pyenv install 3.11)")
else
    pass "Python 3 available as: $PY_BIN"
fi

# Check whether `python` (the bare command) ALSO works — this is the trap.
PYTHON_BARE_OK=0
if command -v python >/dev/null 2>&1; then
    if python -c 'import sys; sys.exit(0 if sys.version_info[0]>=3 else 1)' 2>/dev/null; then
        PYTHON_BARE_OK=1
        pass "'python' (bare command) resolves to Python 3"
    else
        fail "'python' is on PATH but FAILS when executed (likely pyenv shim with no global)"
        note "  This is the #1 cause of MemPalace failures on macOS pyenv setups."
        note "  Test:  python --version  →  see error"
        ROOT_CAUSES+=("Bare 'python' command does not resolve to Python 3 on this machine. Kit hardcodes 'python' in MCP/hook commands → those fail silently. Fix: re-run setup-nexalance.sh after this script (it will auto-detect the right interpreter and patch all configs).")
    fi
else
    warn "'python' (bare command) is not on PATH"
    note "  The kit's older configs use 'python' literally; they will fail."
    ROOT_CAUSES+=("Bare 'python' is not on PATH. Re-run setup-nexalance.sh to migrate configs to use $PY_BIN.")
fi

echo ""

# ─── Check 2: Mempalace package importable from Python 3 ───────
echo "── [2/12] mempalace Python module ──"

if [ -n "$PY_BIN" ]; then
    if "$PY_BIN" -c "import mempalace" 2>/dev/null; then
        VER=$("$PY_BIN" -c "import mempalace; print(getattr(mempalace, '__version__', '?'))" 2>/dev/null)
        pass "mempalace importable via $PY_BIN (version: $VER)"
    else
        fail "mempalace NOT importable via $PY_BIN"
        ROOT_CAUSES+=("mempalace not installed in $PY_BIN. Fix: $PY_BIN -m pip install --user mempalace  OR  pipx install mempalace")
    fi
fi

if [ "$PYTHON_BARE_OK" = "1" ]; then
    if python -c "import mempalace" 2>/dev/null; then
        pass "mempalace importable via 'python'"
    else
        warn "'python' works but mempalace NOT importable via it (may differ from $PY_BIN)"
        note "  This causes inconsistent MCP behavior."
    fi
fi

echo ""

# ─── Check 3: mempalace CLI ──────────────────────────────────
echo "── [3/12] mempalace CLI ──"

if command -v mempalace >/dev/null 2>&1; then
    pass "mempalace CLI found at $(command -v mempalace)"
else
    warn "mempalace CLI not on PATH (the Python module may still work — non-fatal)"
    note "  Fix: ensure pip's user-bin is on PATH (e.g. ~/.local/bin)"
fi

echo ""

# ─── Check 4: MemPalace data directory ───────────────────────
echo "── [4/12] MemPalace data directory ──"

DATA_DIR=""
for cand in "$HOME/mempalace-data" "$HOME/.mempalace" "$HOME/.local/share/mempalace"; do
    if [ -d "$cand" ]; then
        DATA_DIR="$cand"
        break
    fi
done

if [ -n "$DATA_DIR" ]; then
    SIZE=$(du -sh "$DATA_DIR" 2>/dev/null | awk '{print $1}')
    pass "Data dir found: $DATA_DIR  ($SIZE)"
    if [ -w "$DATA_DIR" ]; then
        note "Permissions: writable ✓"
    else
        fail "Permissions: NOT writable"
        ROOT_CAUSES+=("MemPalace data dir not writable. Fix: chmod -R u+w $DATA_DIR")
    fi
else
    warn "No MemPalace data directory found"
    note "  MemPalace will create one on first use, but you may want to run:"
    note "  $PY_BIN -m mempalace init  (or: mempalace init)"
fi

echo ""

# ─── Check 5: claude CLI presence ────────────────────────────
echo "── [5/12] Claude Code CLI ──"

if command -v claude >/dev/null 2>&1; then
    pass "claude CLI at $(command -v claude)"
else
    fail "claude CLI not found — MemPalace cannot work without Claude Code"
    ROOT_CAUSES+=("Install Claude Code: npm install -g @anthropic-ai/claude-code")
fi

echo ""

# ─── Check 6: User-level MCP registration ────────────────────
echo "── [6/12] User-level MCP registration ──"

USER_MCP_OUTPUT=""
if command -v claude >/dev/null 2>&1; then
    USER_MCP_OUTPUT=$(claude mcp list 2>&1 || echo "ERROR")
    if echo "$USER_MCP_OUTPUT" | grep -q "mempalace"; then
        pass "MemPalace registered in user-level MCP config"

        # Inspect the actual command stored
        STORED_CMD=$(echo "$USER_MCP_OUTPUT" | grep -A 5 "mempalace" | head -10)
        note "Stored config:"
        echo "$STORED_CMD" | sed 's/^/      /'

        if echo "$STORED_CMD" | grep -qE '^\s*python\b' || echo "$STORED_CMD" | grep -q '"command":\s*"python"'; then
            if [ "$PYTHON_BARE_OK" = "0" ]; then
                fail "User-level MCP uses 'python' command, but 'python' fails on this machine"
                ROOT_CAUSES+=("User-level MCP is registered with 'python' but only $PY_BIN works. Fix: claude mcp remove mempalace --scope user && claude mcp add mempalace --scope user -- $PY_BIN -m mempalace.mcp_server")
            fi
        fi
    else
        warn "MemPalace not in user-level MCP"
        note "  Fix: claude mcp add mempalace --scope user -- $PY_BIN -m mempalace.mcp_server"
    fi
else
    warn "Skipped — claude CLI unavailable"
fi

echo ""

# ─── Check 7: Project-level .mcp.json ────────────────────────
echo "── [7/12] Project-level .mcp.json ──"

if [ -f .mcp.json ]; then
    if grep -q '"mempalace"' .mcp.json; then
        warn "Project .mcp.json has mempalace entry (likely DUPLICATE with user-level)"
        note "  Symptoms: shows 'failed' at project level, 'connected' at user level."
        note "  The two configs may use different python interpreters → inconsistent behavior."

        # Inspect command
        PROJECT_CMD=$(grep -A 2 '"mempalace"' .mcp.json | grep '"command"' | head -1)
        note "Project command: $PROJECT_CMD"

        if echo "$PROJECT_CMD" | grep -q '"python"'; then
            if [ "$PYTHON_BARE_OK" = "0" ]; then
                fail "Project .mcp.json uses 'python' but it fails on this machine"
                ROOT_CAUSES+=("Project .mcp.json hardcodes 'python'. Fix: remove mempalace from project .mcp.json (user-level handles it), OR rewrite to use $PY_BIN.")
            fi
        fi
    else
        pass "Project .mcp.json present, no duplicate mempalace (user-level handles it)"
    fi
else
    info "No project-level .mcp.json (user-level MCP only — usually correct)"
fi

echo ""

# ─── Check 8: Hooks in .claude/settings.json ─────────────────
echo "── [8/12] .claude/settings.json hooks ──"

if [ -f .claude/settings.json ]; then
    if grep -q "mempalace" .claude/settings.json; then
        HOOK_CMD=$(grep -E "mempalace.hooks" .claude/settings.json | head -2)
        if echo "$HOOK_CMD" | grep -q '\bpython\b' && ! echo "$HOOK_CMD" | grep -q 'python3'; then
            if [ "$PYTHON_BARE_OK" = "0" ]; then
                fail "Hooks invoke 'python -m mempalace.hooks.*' but 'python' fails here"
                note "  Errors are silenced with '2>/dev/null || true' → memory never saves"
                ROOT_CAUSES+=("Hooks use 'python' which fails on this machine. The '|| true' suffix hides the error completely. Fix: re-run setup-project-wing.sh (will auto-patch hooks) OR manually edit .claude/settings.json to use $PY_BIN.")
            else
                pass "Hooks invoke 'python' (works, since 'python' resolves correctly here)"
            fi
        elif echo "$HOOK_CMD" | grep -q 'python3'; then
            pass "Hooks invoke 'python3' (resilient across systems)"
        fi
    else
        warn ".claude/settings.json present but no mempalace hooks"
        note "  Memory won't auto-save. Fix: re-run setup-project-wing.sh"
    fi
else
    warn "No .claude/settings.json"
    note "  Fix: bash setup-project-wing.sh '<wing>' '<name>' '<client>' standard"
fi

echo ""

# ─── Check 9: PROJECT_WING is set (not placeholder) ──────────
echo "── [9/12] PROJECT_WING value ──"

if [ -f CLAUDE.md ]; then
    WING_LINE=$(grep -E '^PROJECT_WING:' CLAUDE.md | head -1)
    WING_VAL=$(echo "$WING_LINE" | sed -E 's/.*PROJECT_WING:[[:space:]]*"([^"]*)".*/\1/')

    if [ -z "$WING_VAL" ]; then
        fail "PROJECT_WING line not found or empty in CLAUDE.md"
        ROOT_CAUSES+=("CLAUDE.md is missing PROJECT_WING. Fix: bash setup-project-wing.sh '<wing>' '<name>' '<client>' standard")
    elif [ "$WING_VAL" = "project-wing-name" ] || [ "$WING_VAL" = "your-wing-name" ]; then
        fail "PROJECT_WING is still the placeholder template value: '$WING_VAL'"
        note "  All MemPalace ops use this wing → wrong wing → no results"
        ROOT_CAUSES+=("PROJECT_WING was never replaced. Fix: bash setup-project-wing.sh '<actual-wing>' '<name>' '<client>' <tier>")
    else
        pass "PROJECT_WING set: '$WING_VAL'"
    fi
else
    fail "No CLAUDE.md in current directory"
    ROOT_CAUSES+=("No CLAUDE.md. Run setup from kit, then setup-project-wing.sh.")
fi

echo ""

# ─── Check 10: Wing actually exists in MemPalace data ────────
echo "── [10/12] Wing has data in MemPalace ──"

if [ -n "$PY_BIN" ] && [ -n "$WING_VAL" ] && [ "$WING_VAL" != "project-wing-name" ]; then
    WING_HAS_DATA=$("$PY_BIN" - <<PYEOF 2>&1
try:
    from mempalace.knowledge_graph import KnowledgeGraph
    kg = KnowledgeGraph()
    triples = kg.search_triples(subject="$WING_VAL")
    print("TRIPLES:", len(list(triples)))
except ImportError:
    print("MEMPALACE_NOT_INSTALLED")
except Exception as e:
    print("ERROR:", str(e)[:120])
PYEOF
)
    case "$WING_HAS_DATA" in
        TRIPLES:\ 0)
            warn "Wing '$WING_VAL' exists but has 0 triples (no data ever saved)"
            note "  Likely cause: wing init failed silently during setup-project-wing.sh"
            ROOT_CAUSES+=("Wing has no data. Re-init: $PY_BIN -c 'from mempalace.knowledge_graph import KnowledgeGraph; KnowledgeGraph().add_triple(\"$WING_VAL\", \"is_project\", \"$(basename $PWD)\")'")
            ;;
        TRIPLES:*)
            COUNT=$(echo "$WING_HAS_DATA" | awk '{print $2}')
            pass "Wing '$WING_VAL' has $COUNT triples (data is being saved)"
            ;;
        MEMPALACE_NOT_INSTALLED)
            fail "mempalace module not importable (already flagged in check 2)"
            ;;
        ERROR:*)
            warn "Could not query wing: ${WING_HAS_DATA#ERROR: }"
            ;;
    esac
else
    info "Skipped (need working Python + valid PROJECT_WING)"
fi

echo ""

# ─── Check 11: TaskMaster MCP doesn't break loading ──────────
echo "── [11/12] TaskMaster MCP (can interfere with MemPalace) ──"

if [ -f .mcp.json ] && grep -q "taskmaster\|task-master-ai" .mcp.json; then
    if command -v npx >/dev/null 2>&1; then
        if timeout 10 npx --yes task-master-ai --version >/dev/null 2>&1; then
            pass "TaskMaster MCP responsive"
        else
            warn "TaskMaster MCP slow/unresponsive — can stall MCP loader and affect MemPalace"
            note "  If MemPalace shows 'connecting' forever, try: remove TaskMaster from .mcp.json"
        fi
    else
        warn "TaskMaster configured but npx not available"
    fi
else
    info "TaskMaster not configured (no risk)"
fi

echo ""

# ─── Check 12: Live MCP test — actually start mempalace.mcp_server ──
echo "── [12/12] Can MemPalace MCP server actually start? ──"

if [ -n "$PY_BIN" ] && "$PY_BIN" -c "import mempalace" 2>/dev/null; then
    # Try to import the MCP server module specifically
    MCP_TEST=$("$PY_BIN" -c "from mempalace import mcp_server; print('OK')" 2>&1)
    if echo "$MCP_TEST" | grep -q "OK"; then
        pass "MCP server module loads cleanly via $PY_BIN"
    else
        fail "MCP server module FAILS to import: ${MCP_TEST:0:200}"
        ROOT_CAUSES+=("MCP server import error: $MCP_TEST. May indicate broken mempalace install. Fix: $PY_BIN -m pip install --upgrade --user mempalace")
    fi
else
    info "Skipped (no working Python with mempalace)"
fi

echo ""

# ═══ Summary ════════════════════════════════════════════════════
echo "═══════════════════════════════════════════════════════════"
echo "📊 SUMMARY"
echo "═══════════════════════════════════════════════════════════"
echo "Passed:   $PASS"
echo "Warnings: $WARN"
echo "Failures: $FAIL"
echo ""

if [ "${#ROOT_CAUSES[@]}" -eq 0 ]; then
    echo -e "${GREEN}🎉 No root causes detected. If MemPalace still misbehaves:${NC}"
    echo "   1. Restart Claude Code (close + reopen)"
    echo "   2. Run: /mcp  (in Claude Code) — check MemPalace status"
    echo "   3. Try a manual save: ask Claude to 'mempalace_status'"
else
    echo -e "${RED}🔧 ROOT CAUSES FOUND (in priority order):${NC}"
    i=1
    for cause in "${ROOT_CAUSES[@]}"; do
        echo ""
        echo -e "${RED}[$i]${NC} $cause"
        i=$((i+1))
    done
    echo ""
    echo "After applying fixes:"
    echo "  1. Restart Claude Code"
    echo "  2. Re-run this diagnostic to confirm"
fi
echo ""
echo "═══════════════════════════════════════════════════════════"
