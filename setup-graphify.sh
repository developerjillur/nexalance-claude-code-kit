#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# NexaLance Graphify Add-On v1.0
# Installs Graphify (codebase knowledge graph) for Claude Code.
# Opt-in. Run AFTER setup-nexalance.sh, ONCE per machine.
# Usage: bash setup-graphify.sh
# ═══════════════════════════════════════════════════════════════

set -e

echo "═══════════════════════════════════════════════════════════"
echo "🕸️  Graphify Add-On — Codebase Knowledge Graph"
echo "═══════════════════════════════════════════════════════════"
echo ""

GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

success() { echo -e "${GREEN}✅ $1${NC}"; }
warn() { echo -e "${YELLOW}⚠️  $1${NC}"; }
fail() { echo -e "${RED}❌ $1${NC}"; }

# ─── Step 1: Prerequisites ───
echo "📋 Step 1: Checking prerequisites..."

if ! command -v claude &> /dev/null; then
    fail "Claude Code CLI not found. Run setup-nexalance.sh first."
    exit 1
fi
success "Claude Code CLI found"

PY_BIN=""
if command -v python3 &> /dev/null; then PY_BIN="python3"
elif command -v python &> /dev/null; then PY_BIN="python"
else
    fail "Python 3.10+ not found. Install Python 3.10+ first."
    exit 1
fi

PY_VERSION=$($PY_BIN -c 'import sys; print(f"{sys.version_info[0]}.{sys.version_info[1]}")')
PY_OK=$($PY_BIN -c 'import sys; print(1 if sys.version_info >= (3,10) else 0)')
if [ "$PY_OK" != "1" ]; then
    fail "Python $PY_VERSION found, but Graphify requires 3.10+. Upgrade Python."
    exit 1
fi
success "Python $PY_VERSION found"

echo ""

# ─── Step 2: Install Graphify (prefer uv → pipx → pip) ───
echo "📋 Step 2: Installing Graphify (PyPI: graphifyy)..."

INSTALLED=0

if command -v uv &> /dev/null; then
    echo "  → Using uv tool install (recommended)..."
    if uv tool install graphifyy 2>/dev/null; then
        success "Graphify installed via uv"
        INSTALLED=1
    else
        warn "uv install failed, falling back..."
    fi
fi

if [ "$INSTALLED" = "0" ] && command -v pipx &> /dev/null; then
    echo "  → Using pipx..."
    if pipx install graphifyy 2>/dev/null; then
        success "Graphify installed via pipx"
        INSTALLED=1
    else
        warn "pipx install failed, falling back..."
    fi
fi

if [ "$INSTALLED" = "0" ]; then
    echo "  → Using pip (with --break-system-packages on macOS if needed)..."
    if pip install graphifyy 2>/dev/null \
        || pip3 install graphifyy 2>/dev/null \
        || pip3 install --user graphifyy 2>/dev/null \
        || pip3 install --break-system-packages graphifyy 2>/dev/null; then
        success "Graphify installed via pip"
        INSTALLED=1
    fi
fi

if [ "$INSTALLED" != "1" ]; then
    fail "Could not install graphifyy automatically."
    echo "    Install manually with one of:"
    echo "      uv tool install graphifyy"
    echo "      pipx install graphifyy"
    echo "      pip install graphifyy"
    exit 1
fi

# Verify CLI is on PATH
if ! command -v graphify &> /dev/null; then
    warn "graphify CLI not on PATH yet. You may need to:"
    echo "    • Restart your shell, OR"
    echo "    • Run: export PATH=\"\$HOME/.local/bin:\$PATH\""
    echo "    • Then re-run this script."
    exit 1
fi
success "graphify CLI on PATH"

echo ""

# ─── Step 3: Install Claude Code skill ───
echo "📋 Step 3: Installing Graphify skill into Claude Code..."

# graphify install / graphify claude install — installs the /graphify slash command
# and writes a PreToolUse hook into ~/.claude/settings.json
if graphify claude install 2>/dev/null; then
    success "Claude Code skill installed (slash command: /graphify)"
elif graphify install 2>/dev/null; then
    success "Claude Code skill installed (slash command: /graphify)"
else
    warn "Skill install via CLI failed. Run manually: graphify claude install"
fi

echo ""

# ─── Step 4: Summary ───
echo "═══════════════════════════════════════════════════════════"
echo "🎉 Graphify Add-On Installed"
echo "═══════════════════════════════════════════════════════════"
echo ""
echo "📝 First-time use, per project:"
echo ""
echo "  cd ~/projects/your-project"
echo "  # Inside Claude Code, run:"
echo "  /graphify ."
echo ""
echo "  This creates ./graphify-out/ with:"
echo "    • graph.json       — queryable knowledge graph"
echo "    • graph.html       — interactive visual graph"
echo "    • GRAPH_REPORT.md  — god nodes, surprising connections"
echo "    • cache/           — SHA256 cache (incremental re-runs)"
echo ""
echo "📝 Common queries (inside Claude Code):"
echo ""
echo "  /graphify query \"how does auth flow work?\""
echo "  /graphify path \"LoginForm\" \"sessionStore\""
echo "  /graphify .  --update      # re-extract changed files only"
echo ""
echo "🧠 The CLAUDE.md rule (already added) tells Claude Code to"
echo "   query graph.json BEFORE Glob/Grep when scanning >20 files."
echo ""
echo "💡 Recommended .gitignore additions per project:"
echo ""
echo "    graphify-out/cache/"
echo "    # keep graph.json + GRAPH_REPORT.md committed if you want shared context"
echo ""
echo "═══════════════════════════════════════════════════════════"
