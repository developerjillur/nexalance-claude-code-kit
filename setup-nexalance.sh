#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# NexaLance Auto-Setup Script v4.3 SUPREME
# One command to install everything. Run ONCE per machine.
# Usage: bash setup-nexalance.sh
# ═══════════════════════════════════════════════════════════════

set -e

echo "═══════════════════════════════════════════════════════════"
echo "🚀 NexaLance Master Project Orchestrator v4.3 — Auto Setup"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
fail() { echo -e "${RED}❌ $1${NC}"; }

# ─── Step 1: Check Prerequisites ───
echo "📋 Step 1: Checking prerequisites..."

if ! command -v claude &> /dev/null; then
    fail "Claude Code CLI not found. Install: npm install -g @anthropic-ai/claude-code"
    exit 1
fi
success "Claude Code CLI found"

# ─── Detect a WORKING Python 3 interpreter (critical for MCP) ───
# Many failures come from hardcoding `python` when only python3 works
# (pyenv users, modern macOS, python3-only systems). We pick the one that
# actually executes and use it consistently for ALL mempalace commands.
PY_BIN=""
for cand in python3 python; do
    if command -v "$cand" >/dev/null 2>&1 && "$cand" -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' 2>/dev/null; then
        PY_BIN="$cand"
        break
    fi
done

if [ -z "$PY_BIN" ]; then
    fail "No working Python 3.x interpreter found."
    fail "  Install Python 3.10+ first: brew install python  OR  pyenv install 3.11 && pyenv global 3.11"
    exit 1
fi
success "Python 3 interpreter: $PY_BIN ($("$PY_BIN" --version 2>&1))"

# Pick a matching pip
PIP_BIN=""
for cand in "${PY_BIN}-pip" pip3 pip; do
    if command -v "$cand" >/dev/null 2>&1; then
        PIP_BIN="$cand"
        break
    fi
done
[ -z "$PIP_BIN" ] && PIP_BIN="$PY_BIN -m pip"
success "Pip command: $PIP_BIN"

if ! command -v node &> /dev/null; then
    fail "Node.js not found. Install Node.js 18+"
    exit 1
fi
success "Node.js found"

if ! command -v git &> /dev/null; then
    fail "Git not found. Install git"
    exit 1
fi
success "Git found"

echo ""

# ─── Step 2: Install MemPalace into the DETECTED Python ───
echo "📋 Step 2: Installing MemPalace into $PY_BIN..."

# Prefer pip with --user so we don't need sudo and avoid system-Python conflicts.
# Try with no flags first (works for venvs + pipx-shimmed pythons), then --user, then --break-system-packages on PEP 668 systems.
if $PIP_BIN install mempalace 2>/dev/null \
   || $PIP_BIN install --user mempalace 2>/dev/null \
   || $PIP_BIN install --break-system-packages mempalace 2>/dev/null; then
    success "mempalace package installed"
else
    fail "mempalace pip install failed. Run manually:  $PIP_BIN install --user mempalace"
    exit 1
fi

# Verify importable from THE SAME interpreter we'll use for MCP/hooks
if "$PY_BIN" -c "import mempalace" 2>/dev/null; then
    VER=$("$PY_BIN" -c "import mempalace; print(getattr(mempalace, '__version__', '?'))" 2>/dev/null)
    success "mempalace importable from $PY_BIN (v$VER)"
else
    fail "mempalace installed but NOT importable from $PY_BIN."
    fail "  This is the #1 cause of MCP failures — the install Python differs from the runtime Python."
    fail "  Try:  $PY_BIN -m pip install --user mempalace"
    exit 1
fi

# Initialize MemPalace data directory
if "$PY_BIN" -m mempalace init 2>/dev/null; then
    success "MemPalace data directory initialized"
elif command -v mempalace >/dev/null 2>&1 && mempalace init 2>/dev/null; then
    success "MemPalace data directory initialized (via mempalace CLI)"
else
    warn "MemPalace init had issues — will be created on first use"
fi

echo ""

# ─── Step 3: Install Claude Code Plugins ───
echo "📋 Step 3: Installing Claude Code plugins..."

echo "  → Adding Superpowers marketplace..."
claude plugin marketplace add obra/superpowers-marketplace 2>/dev/null && \
    success "Superpowers marketplace added" || \
    warn "Superpowers marketplace — run manually: /plugin marketplace add obra/superpowers-marketplace"

echo "  → Installing Superpowers..."
claude plugin install superpowers@superpowers-marketplace 2>/dev/null && \
    success "Superpowers installed" || \
    warn "Superpowers — run manually in Claude Code: /plugin install superpowers@superpowers-marketplace"

# NOTE: We do NOT install the mempalace plugin here.
# The plugin registers its own MCP entry that conflicts with our explicit
# `claude mcp add mempalace` (Step 4). Both end up in `claude mcp list` and
# both can fail. The explicit MCP registration is the supported path.
#
# If you previously installed the plugin and see `plugin:mempalace:mempalace`
# in `claude mcp list` showing "Failed to connect", remove it:
#   claude plugin uninstall mempalace
echo "  → Skipping mempalace plugin install (use explicit MCP registration instead)"
success "MemPalace will be wired via 'claude mcp add' in Step 4"

echo "  → Installing Anthropic Official Plugins..."
claude plugin install code-review@claude-plugins-official 2>/dev/null && \
    success "code-review installed" || \
    warn "code-review — run manually: /plugin install code-review@claude-plugins-official"

claude plugin install feature-dev@claude-plugins-official 2>/dev/null && \
    success "feature-dev installed" || \
    warn "feature-dev — run manually: /plugin install feature-dev@claude-plugins-official"

claude plugin install frontend-design@claude-plugins-official 2>/dev/null && \
    success "frontend-design installed" || \
    warn "frontend-design — run manually: /plugin install frontend-design@claude-plugins-official"

echo ""

# ─── Step 3.5: Install Browser Tools ───
echo "📋 Step 3.5: Installing browser automation tools..."

echo "  → Installing Playwright CLI (4x more token efficient than MCP)..."
npm install -g @playwright/cli 2>/dev/null && \
    success "Playwright CLI installed" || \
    warn "Playwright CLI — run manually: npm install -g @playwright/cli"

echo "  → Installing Chromium browser..."
npx playwright install chromium 2>/dev/null && \
    success "Chromium installed" || \
    warn "Chromium — run manually: npx playwright install chromium"

echo "  → Configuring Chrome DevTools MCP (browser debugging)..."
claude mcp add chrome-devtools --scope user -- npx chrome-devtools-mcp@latest 2>/dev/null && \
    success "Chrome DevTools MCP configured" || \
    warn "Chrome DevTools — run manually: claude mcp add chrome-devtools --scope user -- npx chrome-devtools-mcp@latest"

echo ""

# ─── Step 3.6: Install Design Quality Tools ───
echo "📋 Step 3.6: Installing design quality tools..."

echo "  → Installing ShadcnBlocks skill (2,500+ UI blocks)..."
claude plugin add github:masonjames/Shadcnblocks-Skill 2>/dev/null && \
    success "ShadcnBlocks skill installed" || \
    warn "ShadcnBlocks — run manually: claude plugin add github:masonjames/Shadcnblocks-Skill"

echo "  → Installing Vercel Web Design Guidelines..."
npx skills add vercel-labs/agent-skills 2>/dev/null && \
    success "Vercel design guidelines installed" || \
    warn "Vercel guidelines — run manually: npx skills add vercel-labs/agent-skills"

echo ""

# ─── Step 4: Configure MemPalace MCP (user-level, with DETECTED interpreter) ───
echo "📋 Step 4: Configuring MemPalace MCP (user-level)..."

# Resolve to absolute path so MCP doesn't depend on shell PATH at server start
PY_ABS=$(command -v "$PY_BIN")

# Remove any existing entry first (avoid stale config with wrong interpreter)
claude mcp remove mempalace --scope user 2>/dev/null || true

# Register with the detected absolute path — errors are NOT silenced this time
if claude mcp add mempalace --scope user -- "$PY_ABS" -m mempalace.mcp_server; then
    success "MemPalace MCP registered (user-level) using: $PY_ABS -m mempalace.mcp_server"
else
    fail "MemPalace MCP registration failed. Run manually:"
    fail "  claude mcp add mempalace --scope user -- $PY_ABS -m mempalace.mcp_server"
fi

# Quick liveness probe
if claude mcp list 2>&1 | grep -q "mempalace.*Connected"; then
    success "MemPalace MCP shows 'Connected' in claude mcp list"
elif claude mcp list 2>&1 | grep -q "mempalace.*Failed"; then
    warn "MemPalace MCP shows 'Failed' — run: bash diagnose-mempalace.sh"
fi

echo ""

# ─── Step 5: Configure Hooks ───
echo "📋 Step 5: Configuring auto-save hooks..."

CLAUDE_HOME="$HOME/.claude"
SETTINGS_FILE="$CLAUDE_HOME/settings.json"

# Create backup if settings exist
if [ -f "$SETTINGS_FILE" ]; then
    cp "$SETTINGS_FILE" "$SETTINGS_FILE.backup.$(date +%Y%m%d%H%M%S)"
    warn "Existing settings backed up"
fi

# Check if hooks already configured
if [ -f "$SETTINGS_FILE" ] && grep -q "mempalace" "$SETTINGS_FILE" 2>/dev/null; then
    success "MemPalace hooks already configured"
else
    # Add hooks using Python to safely merge JSON.
    # Critical: hooks use the DETECTED interpreter (not bare `python`) and
    # log failures to a file instead of swallowing them silently.
    PY_FOR_HOOKS="$PY_ABS" "$PY_BIN" - <<PYEOF
import json, os

PY = os.environ['PY_FOR_HOOKS']
settings_file = os.path.expanduser('~/.claude/settings.json')
settings = {}

if os.path.exists(settings_file):
    try:
        with open(settings_file) as f:
            settings = json.load(f)
    except Exception:
        settings = {}

settings.setdefault('hooks', {})

# Save hook — failures log to ~/.mempalace-hook.log instead of being lost
settings['hooks']['Stop'] = [{
    'matcher': '',
    'hooks': [{
        'type': 'command',
        'command': f'{PY} -m mempalace.hooks.save_hook 2>>~/.mempalace-hook.log || true'
    }]
}]

settings['hooks']['PreCompact'] = [{
    'matcher': '',
    'hooks': [{
        'type': 'command',
        'command': f'{PY} -m mempalace.hooks.precompact_hook 2>>~/.mempalace-hook.log || true'
    }]
}]

os.makedirs(os.path.dirname(settings_file), exist_ok=True)
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print('Hooks written successfully using interpreter:', PY)
PYEOF
    if [ $? -eq 0 ]; then
        success "Auto-save hooks configured (interpreter: $PY_ABS, errors log to ~/.mempalace-hook.log)"
    else
        warn "Hooks — configure manually in ~/.claude/settings.json"
    fi
fi

echo ""

# ─── Step 6: Verify Installation ───
echo "═══════════════════════════════════════════════════════════"
echo "📋 Step 6: Verification Summary"
echo "═══════════════════════════════════════════════════════════"
echo ""

# Check each component
echo "Plugins:"
command -v mempalace &> /dev/null && success "  MemPalace CLI" || warn "  MemPalace CLI (check pip install)"
python3 -c "import mempalace" 2>/dev/null && success "  MemPalace Python" || warn "  MemPalace Python module"
command -v playwright-cli &> /dev/null && success "  Playwright CLI" || warn "  Playwright CLI (check npm install)"
echo ""

echo "Hooks:"
if [ -f "$SETTINGS_FILE" ] && grep -q "save_hook" "$SETTINGS_FILE" 2>/dev/null; then
    success "  Auto-save hook (every 15 messages)"
    success "  Pre-compact hook (before /compact)"
else
    warn "  Hooks not detected in settings.json"
fi
echo ""

echo "═══════════════════════════════════════════════════════════"
echo "🎉 SETUP COMPLETE! v4.3 SUPREME"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📝 Next Steps (for EACH new project):"
echo ""
echo "  mkdir ~/projects/PROJECT_NAME"
echo "  cd ~/projects/PROJECT_NAME"
echo "  cp ~/nexalance-kit/NexaLance-CLAUDE-v4.3-SUPREME.md ./CLAUDE.md"
echo "  bash ~/nexalance-kit/setup-project-wing.sh \"wing-name\" \"Project Name\" \"client\""
echo "  # Put PRD in docs/PRD.md"
echo "  code ."
echo "  # Claude Code → 'Start project'"
echo ""
echo "🔌 Installed Tools:"
echo "  • Superpowers (brainstorm + plan + TDD)"
echo "  • MemPalace (persistent memory across sessions)"
echo "  • Code Review (5-agent parallel review)"
echo "  • Feature Dev (7-phase implementation)"
echo "  • Frontend Design (quality UI)"
echo "  • ShadcnBlocks (2,500+ professional UI blocks)"
echo "  • Vercel Design Guidelines (100+ UX rules)"
echo "  • Playwright CLI (token-efficient browser testing)"
echo "  • Chrome DevTools MCP (browser debugging)"
echo "  • Auto-save hooks (every 15 messages)"
echo ""
echo "🧠 Everything is AUTOMATIC. No commands to remember."
echo ""
echo "═══════════════════════════════════════════════════════════"
