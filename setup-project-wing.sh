#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# NexaLance — New Project Wing Setup
# Creates isolated MemPalace wing for a project workspace
# Usage: bash setup-project-wing.sh "wing-name" "Project Name" "client"
# ═══════════════════════════════════════════════════════════════

WING=$1
PROJECT_NAME=$2
CLIENT=${3:-"unspecified"}

if [ -z "$WING" ] || [ -z "$PROJECT_NAME" ]; then
    echo "═══════════════════════════════════════════════"
    echo "🏗️  NexaLance — Project Wing Setup"
    echo "═══════════════════════════════════════════════"
    echo ""
    echo "Usage: bash setup-project-wing.sh <wing> <name> [client]"
    echo ""
    echo "Examples:"
    echo "  bash setup-project-wing.sh autofointparts 'Auto Foreign Parts E-commerce' mzahra98"
    echo "  bash setup-project-wing.sh psychgate 'PsychGate AI Health' bfenwick22"
    echo "  bash setup-project-wing.sh nexascalp 'NexaScalp AI Trading Bot'"
    echo ""
    exit 1
fi

echo "═══════════════════════════════════════════════"
echo "🏗️  Setting up: $PROJECT_NAME"
echo "   Wing: $WING | Client: $CLIENT"
echo "═══════════════════════════════════════════════"
echo ""

# Create directories
mkdir -p docs/{reviews,analysis,plans} .claude/commands .screenshots/{tests,reviews,deployments,bugs}
echo "✅ Created docs/ (reviews, analysis, plans) + .claude/ + .screenshots/"

# Check CLAUDE.md exists
if [ ! -f "CLAUDE.md" ]; then
    echo "❌ CLAUDE.md not found!"
    echo "   Copy NexaLance-CLAUDE-v4.1-SUPREME.md as CLAUDE.md first:"
    echo "   cp /path/to/NexaLance-CLAUDE-v4.1-SUPREME.md ./CLAUDE.md"
    exit 1
fi

# Add PROJECT_WING to CLAUDE.md
if grep -q "PROJECT_WING" CLAUDE.md; then
    echo "⚠️  PROJECT_WING already exists — updating..."
    sed -i "s/PROJECT_WING: .*/PROJECT_WING: \"$WING\"/" CLAUDE.md
    sed -i "s/PROJECT_NAME: .*/PROJECT_NAME: \"$PROJECT_NAME\"/" CLAUDE.md
    sed -i "s/CLIENT: .*/CLIENT: \"$CLIENT\"/" CLAUDE.md
else
    TEMP=$(mktemp)
    cat > "$TEMP" << HEADER
## 🏷️ PROJECT IDENTITY
PROJECT_WING: "$WING"
PROJECT_NAME: "$PROJECT_NAME"
CLIENT: "$CLIENT"

---

HEADER
    cat CLAUDE.md >> "$TEMP"
    mv "$TEMP" CLAUDE.md
fi
echo "✅ PROJECT_WING: \"$WING\" added to CLAUDE.md"

# Create .mcp.json with MemPalace + TaskMaster
cat > .mcp.json << 'MCP'
{
  "mcpServers": {
    "mempalace": {
      "command": "python",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {}
    },
    "taskmaster": {
      "command": "npx",
      "args": ["-y", "task-master-ai"],
      "env": {
        "TASK_MASTER_TOOLS": "standard"
      }
    }
  }
}
MCP
echo "✅ .mcp.json created (MemPalace + TaskMaster)"

# Create hooks settings
mkdir -p .claude
cat > .claude/settings.json << 'SETTINGS'
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python -m mempalace.hooks.save_hook 2>/dev/null || true"
          }
        ]
      }
    ],
    "PreCompact": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python -m mempalace.hooks.precompact_hook 2>/dev/null || true"
          }
        ]
      }
    ]
  }
}
SETTINGS
echo "✅ Auto-save hooks configured"

# Create wing-aware auto-orchestrator skill
cat > .claude/commands/auto-orchestrator.md << 'SKILL'
# Auto-Orchestrator — NexaLance Plugin Engine (Wing-Aware)
# Reads PROJECT_WING from CLAUDE.md → routes all MemPalace to correct wing
---
name: auto-orchestrator
description: |
  ALWAYS active. Reads PROJECT_WING from CLAUDE.md.
  All MemPalace calls auto-filtered by project wing.
  Zero context bleed between projects.
---

## WING ISOLATION PROTOCOL

On EVERY session start:
1. Read CLAUDE.md → extract PROJECT_WING value
2. Set CURRENT_WING = that value
3. ALL MemPalace operations MUST include --wing CURRENT_WING:
   - mempalace_search "query" --wing CURRENT_WING
   - mempalace_add_drawer "content" --wing CURRENT_WING
   - mempalace_kg_add ... --wing CURRENT_WING
   - mempalace_diary_write ... --wing CURRENT_WING
4. NEVER call MemPalace without --wing filter
5. This keeps project memories 100% isolated

## AUTO-ROOM DETECTION

When saving, detect room from context:
| Working on | Room |
|-----------|------|
| Auth, login, JWT | auth |
| Database, schema, migrations | database |
| API, controllers, routes | api |
| Frontend, UI, components | frontend |
| Payment, Stripe, billing | payments |
| Deploy, Docker, CI/CD | deployment |
| Tests, E2E, Playwright | testing |
| Business logic, rules | business-logic |
| Third-party APIs | integrations |
| Architecture decisions | architecture |

## AUTO-TRIGGER TABLE

| Context | Action |
|---------|--------|
| Session starts | mempalace_status → mempalace_search --wing CURRENT_WING |
| New project init | brainstorm → plan → generate docs |
| Complex feature | /feature-dev (7-phase) |
| Frontend work | frontend-design auto-activates |
| Task completed | /code-review → self-rate → mempalace save --wing CURRENT_WING |
| Every 3 tasks | mempalace_add_drawer --wing CURRENT_WING |
| Decision made | mempalace_kg_add --wing CURRENT_WING |
| Session ending | Exit Gate → mempalace_diary_write --wing CURRENT_WING |
| Context heavy | Emergency save → suggest /compact or new session |

## SEAMLESS BEHAVIOR
- Use plugins SILENTLY — don't announce plugin names
- User sees ONE intelligent system, not multiple plugins
- If plugin missing → fall back to manual approach silently
- MemPalace saves are BACKGROUND — never announce unless asked
SKILL
echo "✅ Wing-aware auto-orchestrator skill created"

# Create initial docs
if [ ! -f "docs/SESSION.md" ]; then
    cat > docs/SESSION.md << SESSION
# Session Tracker — $PROJECT_NAME
## MemPalace Wing: $WING

## Current State
- Phase: 0 (Not started)
- Last completed: None
- Current task: Waiting for PRD
- Blockers: None

## Session History
| # | Date | Tasks Done | Phase Progress | Notes |
|---|------|-----------|----------------|-------|

## Next Actions
1. Provide PRD in docs/PRD.md
2. Say "Start project" in Claude Code
SESSION
    echo "✅ docs/SESSION.md created"
fi

if [ ! -f "docs/HANDOFF.md" ]; then
    cat > docs/HANDOFF.md << HANDOFF
# Session Handoff — $PROJECT_NAME
## MemPalace Wing: $WING
## Client: $CLIENT

## Project Overview
[Will be filled after Phase 0]

## Current State
- Phase: Not started
- Waiting for PRD

## RESUME INSTRUCTIONS
1. MemPalace: mempalace_search "$WING" --wing $WING
2. Read this file
3. Read docs/SESSION.md
4. Continue from where left off
HANDOFF
    echo "✅ docs/HANDOFF.md created"
fi

# Initialize git if not already
if [ ! -d ".git" ]; then
    git init
    cat > .gitignore << 'GITIGNORE'
node_modules/
.env
.env.local
dist/
build/
*.log
.DS_Store
__pycache__/
.screenshots/
.playwright-cli/
GITIGNORE
    git add -A
    git commit -m "chore: initialize $PROJECT_NAME workspace with NexaLance orchestrator"
    echo "✅ Git initialized"
else
    echo "⚠️  Git already initialized"
fi

# Try to initialize MemPalace wing
python3 -c "
from mempalace.knowledge_graph import KnowledgeGraph
kg = KnowledgeGraph()
kg.add_triple('$WING', 'is_project', '$PROJECT_NAME', valid_from='$(date +%Y-%m-%d)')
kg.add_triple('$WING', 'client', '$CLIENT', valid_from='$(date +%Y-%m-%d)')
kg.add_triple('$WING', 'status', 'active', valid_from='$(date +%Y-%m-%d)')
print('✅ MemPalace wing \"$WING\" initialized with knowledge graph')
" 2>/dev/null || echo "⚠️  MemPalace KG init skipped (will init on first session)"

echo ""
echo "═══════════════════════════════════════════════"
echo "🎉 DONE! Project workspace ready."
echo "═══════════════════════════════════════════════"
echo ""
echo "📁 Your workspace:"
echo "   CLAUDE.md          ← PROJECT_WING: \"$WING\""
echo "   .mcp.json          ← MemPalace + TaskMaster"
echo "   .claude/settings   ← Auto-save hooks"
echo "   .claude/commands/  ← Wing-aware orchestrator"
echo "   docs/SESSION.md    ← Session tracker"
echo "   docs/HANDOFF.md    ← Session handoff"
echo ""
echo "📝 Next:"
echo "   1. Put your PRD → docs/PRD.md"
echo "   2. Open Claude Code: claude"
echo "   3. Say: 'Start project'"
echo ""
echo "🧠 MemPalace wing: \"$WING\""
echo "   All memories isolated to this project."
echo "   Switch projects = switch folders = switch context."
echo ""
