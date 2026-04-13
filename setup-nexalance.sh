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

if ! command -v python3 &> /dev/null && ! command -v python &> /dev/null; then
    fail "Python not found. Install Python 3.9+"
    exit 1
fi
success "Python found"

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

# ─── Step 2: Install MemPalace ───
echo "📋 Step 2: Installing MemPalace (persistent memory)..."

if pip install mempalace 2>/dev/null || pip3 install mempalace 2>/dev/null; then
    success "MemPalace installed"
else
    warn "MemPalace pip install failed. Try manually: pip install mempalace"
fi

# Initialize MemPalace
if command -v mempalace &> /dev/null; then
    mempalace init 2>/dev/null || true
    success "MemPalace initialized"
else
    warn "MemPalace CLI not found in PATH. May need: python -m mempalace init"
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

echo "  → Installing MemPalace plugin..."
claude plugin marketplace add milla-jovovich/mempalace 2>/dev/null && \
claude plugin install --scope user mempalace 2>/dev/null && \
    success "MemPalace plugin installed" || \
    warn "MemPalace plugin — run manually: claude plugin install --scope user mempalace"

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

# ─── Step 4: Configure MemPalace MCP (user-level) ───
echo "📋 Step 4: Configuring MCP servers (user-level)..."

claude mcp add mempalace --scope user -- python -m mempalace.mcp_server 2>/dev/null && \
    success "MemPalace MCP configured (user-level)" || \
    warn "MemPalace MCP — run manually: claude mcp add mempalace --scope user -- python -m mempalace.mcp_server"

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
    # Add hooks using Python to safely merge JSON
    python3 -c "
import json, os

settings_file = os.path.expanduser('~/.claude/settings.json')
settings = {}

if os.path.exists(settings_file):
    with open(settings_file) as f:
        try:
            settings = json.load(f)
        except:
            settings = {}

# Add hooks
if 'hooks' not in settings:
    settings['hooks'] = {}

settings['hooks']['Stop'] = [{
    'matcher': '',
    'hooks': [{
        'type': 'command',
        'command': 'python -m mempalace.hooks.save_hook 2>/dev/null || true'
    }]
}]

settings['hooks']['PreCompact'] = [{
    'matcher': '',
    'hooks': [{
        'type': 'command',
        'command': 'python -m mempalace.hooks.precompact_hook 2>/dev/null || true'
    }]
}]

os.makedirs(os.path.dirname(settings_file), exist_ok=True)
with open(settings_file, 'w') as f:
    json.dump(settings, f, indent=2)

print('Hooks configured successfully')
" 2>/dev/null && success "Auto-save hooks configured" || warn "Hooks — configure manually in ~/.claude/settings.json"
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
