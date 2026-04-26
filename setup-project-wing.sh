#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# NexaLance — New Project Wing Setup
# Creates isolated MemPalace wing for a project workspace
# Usage: bash setup-project-wing.sh "wing-name" "Project Name" "client"
# ═══════════════════════════════════════════════════════════════

WING=$1
PROJECT_NAME=$2
CLIENT=${3:-"unspecified"}
TIER=${4:-"standard"}

# Validate tier
case "$TIER" in
    lite|standard|full) ;;
    *)
        echo "❌ Invalid tier: '$TIER'. Must be: lite | standard | full"
        exit 1
        ;;
esac

if [ -z "$WING" ] || [ -z "$PROJECT_NAME" ]; then
    echo "═══════════════════════════════════════════════"
    echo "🏗️  NexaLance — Project Wing Setup"
    echo "═══════════════════════════════════════════════"
    echo ""
    echo "Usage: bash setup-project-wing.sh <wing> <name> [client] [tier]"
    echo ""
    echo "  tier: lite | standard | full   (default: standard)"
    echo "    lite     → DESIGN + SCHEMA + SESSION  (3 docs, MVPs/prototypes)"
    echo "    standard → + TAD + API + RULES        (6 docs, most production)"
    echo "    full     → + FEATURES + TASKS + TESTING (9 docs, enterprise)"
    echo ""
    echo "Examples:"
    echo "  bash setup-project-wing.sh autofointparts 'Auto Foreign Parts E-commerce' mzahra98 standard"
    echo "  bash setup-project-wing.sh psychgate 'PsychGate AI Health' bfenwick22 full"
    echo "  bash setup-project-wing.sh nexascalp 'NexaScalp AI Trading Bot' '' lite"
    echo ""
    exit 1
fi

echo "═══════════════════════════════════════════════"
echo "🏗️  Setting up: $PROJECT_NAME"
echo "   Wing: $WING | Client: $CLIENT | Tier: $TIER"
echo "═══════════════════════════════════════════════"
echo ""

# ─── Detect a working Python 3 interpreter (must match setup-nexalance.sh) ───
PY_BIN=""
for cand in python3 python; do
    if command -v "$cand" >/dev/null 2>&1 && "$cand" -c 'import sys; sys.exit(0 if sys.version_info[0] >= 3 else 1)' 2>/dev/null; then
        PY_BIN="$cand"
        break
    fi
done
if [ -z "$PY_BIN" ]; then
    echo "❌ No working Python 3 interpreter found. Install Python 3.10+ first."
    exit 1
fi
PY_ABS=$(command -v "$PY_BIN")
echo "🐍 Using Python: $PY_ABS"
echo ""

# ─── Validate WING is not the placeholder template value ───
case "$WING" in
    project-wing-name|your-wing-name|"")
        echo "❌ Refusing to use placeholder wing name '$WING'."
        echo "   Pick a real wing identifier (lowercase-hyphenated, e.g. 'my-saas-app')."
        exit 1
        ;;
esac

# Create directories
mkdir -p docs/{reviews,analysis,plans} .claude/commands .screenshots/{tests,reviews,deployments,bugs}
echo "✅ Created docs/ (reviews, analysis, plans) + .claude/ + .screenshots/"

# Check CLAUDE.md exists
if [ ! -f "CLAUDE.md" ]; then
    echo "❌ CLAUDE.md not found!"
    echo "   Copy the v4.4 LITE template first:"
    echo "     cp /path/to/nexalance-kit/NexaLance-CLAUDE-v4.4-LITE.md ./CLAUDE.md"
    echo "     cp -r /path/to/nexalance-kit/playbooks ./playbooks"
    echo ""
    echo "   (For migrating an existing v4.3-based project,"
    echo "    use: bash /path/to/nexalance-kit/migrate-to-v44.sh)"
    exit 1
fi

# Detect template version. v4.4 LITE is the supported path.
# Legacy v4.3-based CLAUDE.md is still recognized so this script can be
# safely re-run on older projects (use migrate-to-v44.sh to upgrade them).
if grep -q "v4.4 LITE" CLAUDE.md; then
    TEMPLATE_VERSION="v4.4-LITE"
    if [ ! -d "playbooks" ]; then
        echo "⚠️  v4.4 LITE detected but ./playbooks/ folder missing in project."
        echo "   Copy it: cp -r /path/to/nexalance-kit/playbooks ./playbooks"
    fi
else
    TEMPLATE_VERSION="v4.3-legacy"
    echo "ℹ️  Detected legacy v4.3-style CLAUDE.md — to upgrade to v4.4 LITE:"
    echo "    bash /path/to/nexalance-kit/migrate-to-v44.sh standard"
fi
echo "✅ Detected CLAUDE.md template: $TEMPLATE_VERSION"

# Add/update PROJECT_WING + PROJECT_TIER in CLAUDE.md
if grep -q "PROJECT_WING" CLAUDE.md; then
    echo "⚠️  PROJECT_WING already exists — updating..."
    # Use a sed wrapper that works on both BSD (macOS) and GNU sed
    sedi() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }
    sedi "s/PROJECT_WING: .*/PROJECT_WING:    \"$WING\"/" CLAUDE.md
    sedi "s/PROJECT_NAME: .*/PROJECT_NAME:    \"$PROJECT_NAME\"/" CLAUDE.md
    sedi "s/CLIENT: .*/CLIENT:          \"$CLIENT\"/" CLAUDE.md
    if grep -q "PROJECT_TIER" CLAUDE.md; then
        sedi "s/PROJECT_TIER: .*/PROJECT_TIER:    \"$TIER\"/" CLAUDE.md
    else
        # Insert PROJECT_TIER after CLIENT line
        sedi "/CLIENT:.*/a\\
PROJECT_TIER:    \"$TIER\"   ← lite | standard | full  (controls Phase 0 doc set)
" CLAUDE.md
    fi
else
    TEMP=$(mktemp)
    cat > "$TEMP" << HEADER
## 🏷️ PROJECT IDENTITY
PROJECT_WING:    "$WING"
PROJECT_NAME:    "$PROJECT_NAME"
CLIENT:          "$CLIENT"
PROJECT_TIER:    "$TIER"

---

HEADER
    cat CLAUDE.md >> "$TEMP"
    mv "$TEMP" CLAUDE.md
fi
echo "✅ PROJECT_WING: \"$WING\" + PROJECT_TIER: \"$TIER\" written to CLAUDE.md"

# Create .mcp.json — TaskMaster only (project-specific).
# MemPalace is intentionally NOT registered at project level: it's already
# user-level (via setup-nexalance.sh) and a duplicate entry causes the known
# "Failed to connect at project level / Connected at user level" symptom.
# If user-level mempalace is missing, run setup-nexalance.sh.
cat > .mcp.json << 'MCP'
{
  "mcpServers": {
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
echo "✅ .mcp.json created (TaskMaster only — MemPalace lives at user-level to avoid duplicates)"

# Copy v4.4 LITE hook scripts to project (.claude/hooks/) — only if v4.4 LITE
mkdir -p .claude .claude/hooks .claude/commands

# Locate the kit directory (relative to this script)
KIT_DIR=$(cd "$(dirname "$0")" && pwd)

if [ "$TEMPLATE_VERSION" = "v4.4-LITE" ] && [ -d "$KIT_DIR/hooks" ]; then
    cp "$KIT_DIR/hooks/playbook-tracker.sh" .claude/hooks/ 2>/dev/null
    cp "$KIT_DIR/hooks/reset-counter.sh"    .claude/hooks/ 2>/dev/null
    cp "$KIT_DIR/hooks/cache-warn.sh"       .claude/hooks/ 2>/dev/null
    chmod +x .claude/hooks/*.sh 2>/dev/null
    HOOKS_INSTALLED=1
    echo "✅ v4.4 LITE hooks installed to .claude/hooks/"
else
    HOOKS_INSTALLED=0
    if [ "$TEMPLATE_VERSION" = "v4.4-LITE" ]; then
        echo "⚠️  v4.4 LITE detected but kit hooks/ folder not found at $KIT_DIR/hooks"
    fi
fi

# Write .claude/settings.json with hooks (tier-aware)
if [ "$HOOKS_INSTALLED" = "1" ]; then
    cat > .claude/settings.json << 'SETTINGS'
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "PY_BIN_PLACEHOLDER -m mempalace.hooks.save_hook 2>>~/.mempalace-hook.log || true"
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
            "command": "PY_BIN_PLACEHOLDER -m mempalace.hooks.precompact_hook 2>>~/.mempalace-hook.log || true"
          }
        ]
      }
    ],
    "PreToolUse": [
      {
        "matcher": "Read",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/playbook-tracker.sh"
          }
        ]
      },
      {
        "matcher": "Edit|Write|MultiEdit",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/cache-warn.sh"
          }
        ]
      }
    ],
    "UserPromptSubmit": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/reset-counter.sh"
          }
        ]
      }
    ]
  }
}
SETTINGS
    echo "✅ Hooks wired into .claude/settings.json (MemPalace + playbook-tracker + cache-warn + reset-counter)"
else
    # v4.3 legacy — original 2 hooks only
    cat > .claude/settings.json << 'SETTINGS'
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "PY_BIN_PLACEHOLDER -m mempalace.hooks.save_hook 2>>~/.mempalace-hook.log || true"
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
            "command": "PY_BIN_PLACEHOLDER -m mempalace.hooks.precompact_hook 2>>~/.mempalace-hook.log || true"
          }
        ]
      }
    ]
  }
}
SETTINGS
    echo "✅ Auto-save hooks configured (v4.3 mode)"
fi

# Substitute PY_BIN_PLACEHOLDER → actual detected interpreter (absolute path).
# This is what fixes the #1 MemPalace bug: hardcoded `python` failing on
# pyenv / python3-only systems. Use sed wrapper that works on BSD + GNU.
if grep -q "PY_BIN_PLACEHOLDER" .claude/settings.json 2>/dev/null; then
    sedi() { if sed --version >/dev/null 2>&1; then sed -i "$@"; else sed -i '' "$@"; fi; }
    # Escape forward slashes in PY_ABS for sed
    PY_ABS_ESCAPED=$(printf '%s\n' "$PY_ABS" | sed 's:/:\\/:g')
    sedi "s/PY_BIN_PLACEHOLDER/$PY_ABS_ESCAPED/g" .claude/settings.json
    echo "✅ Hook commands patched to use $PY_ABS"
fi

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
    if [ "$TIER" = "full" ]; then
        # Full tier — uses dedicated FEATURES.md, no Feature Tracker in SESSION.md
        cat > docs/SESSION.md << SESSION
# Session Tracker — $PROJECT_NAME
## MemPalace Wing: $WING
## Project Tier: $TIER

## Current State
- Tier: $TIER
- Phase: 0 (Not started)
- Last completed: None
- Current task: Waiting for PRD
- Blockers: None
- Context health: Fresh

## Session History
| # | Date | Tasks Done | Phase Progress | Notes |
|---|------|-----------|----------------|-------|

## Next Actions
1. Provide PRD in docs/PRD.md
2. Say "Start project" in Claude Code

> Full tier: feature progress is tracked in docs/FEATURES.md (auto-generated in Phase 0).
SESSION
    else
        # Lite / Standard tier — INCLUDES Feature Tracker section
        cat > docs/SESSION.md << SESSION
# Session Tracker — $PROJECT_NAME
## MemPalace Wing: $WING
## Project Tier: $TIER

## Current State
- Tier: $TIER
- Phase: 0 (Not started)
- Last completed: None
- Current task: Waiting for PRD
- Blockers: None
- Context health: Fresh

## Feature Tracker (Lite/Standard tier — replaces FEATURES.md)
| ID | Feature | Priority | Status | Files | Tested ✅ | Working ✅ | Notes |
|----|---------|----------|--------|-------|-----------|-----------|-------|
| F-001 | _(populated from PRD in Phase 0)_ | - | ⏳ pending | - | ❌ | ❌ | - |

Status legend: ⏳ pending | 🚧 in progress | ✅ done | ⚠️ blocked

> On every feature completion, update the row's Status, Files, Tested, Working columns.
> This table IS the single source of truth for feature progress in $TIER-tier projects.

## Session History
| # | Date | Tasks Done | Phase Progress | Notes |
|---|------|-----------|----------------|-------|

## Next Actions
1. Provide PRD in docs/PRD.md
2. Say "Start project" in Claude Code
SESSION
    fi
    echo "✅ docs/SESSION.md created (tier: $TIER, $([ "$TIER" = "full" ] && echo "uses FEATURES.md" || echo "with Feature Tracker"))"
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
.claude/.playbook-counter
graphify-out/cache/
GITIGNORE
    git add -A
    git commit -m "chore: initialize $PROJECT_NAME workspace with NexaLance orchestrator"
    echo "✅ Git initialized"
else
    echo "⚠️  Git already initialized"
fi

# Initialize MemPalace wing using the DETECTED interpreter.
# Errors are now VISIBLE — silent failure here was causing wings to never
# get data, leading to the "MemPalace returns nothing about my project" symptom.
INIT_OUT=$("$PY_BIN" - <<PYEOF 2>&1
try:
    from mempalace.knowledge_graph import KnowledgeGraph
    kg = KnowledgeGraph()
    kg.add_triple('$WING', 'is_project', '$PROJECT_NAME', valid_from='$(date +%Y-%m-%d)')
    kg.add_triple('$WING', 'client', '$CLIENT', valid_from='$(date +%Y-%m-%d)')
    kg.add_triple('$WING', 'status', 'active', valid_from='$(date +%Y-%m-%d)')
    kg.add_triple('$WING', 'tier', '$TIER', valid_from='$(date +%Y-%m-%d)')
    print('OK')
except ImportError as e:
    print('IMPORT_ERROR:', e)
except Exception as e:
    print('ERROR:', e)
PYEOF
)
case "$INIT_OUT" in
    OK)
        echo "✅ MemPalace wing \"$WING\" initialized (4 triples seeded)"
        ;;
    IMPORT_ERROR:*)
        echo "❌ MemPalace not importable from $PY_BIN — wing NOT initialized."
        echo "   ${INIT_OUT}"
        echo "   Fix: $PY_BIN -m pip install --user mempalace  (then re-run this script)"
        echo "   Or run: bash $(cd "$(dirname "$0")" && pwd)/diagnose-mempalace.sh"
        ;;
    ERROR:*)
        echo "⚠️  MemPalace KG init failed: ${INIT_OUT}"
        echo "   Wing may already exist (this is fine if migrating). Continuing..."
        ;;
    *)
        echo "⚠️  Unexpected output from MemPalace init: ${INIT_OUT}"
        ;;
esac

echo ""
echo "═══════════════════════════════════════════════"
echo "🎉 DONE! Project workspace ready."
echo "═══════════════════════════════════════════════"
echo ""
echo "📁 Your workspace:"
echo "   CLAUDE.md          ← PROJECT_WING: \"$WING\" | TIER: \"$TIER\" ($TEMPLATE_VERSION)"
echo "   .mcp.json          ← MemPalace + TaskMaster"
echo "   .claude/settings.json ← Hooks: MemPalace$([ "$HOOKS_INSTALLED" = "1" ] && echo " + playbook-tracker + cache-warn + reset-counter")"
if [ "$HOOKS_INSTALLED" = "1" ]; then
echo "   .claude/hooks/     ← v4.4 LITE enforcement hooks (3 scripts)"
fi
echo "   .claude/commands/  ← Wing-aware orchestrator"
echo "   docs/SESSION.md    ← Session tracker$([ "$TIER" != "full" ] && echo " (with Feature Tracker)")"
echo "   docs/HANDOFF.md    ← Session handoff"
if [ "$TEMPLATE_VERSION" = "v4.4-LITE" ]; then
echo "   playbooks/         ← Lazy-loaded modules (read on demand)"
fi
echo ""
echo "📊 Phase 0 will generate (per tier '$TIER'):"
case "$TIER" in
    lite)     echo "   DESIGN.md + SCHEMA.md + SESSION.md (3 docs)" ;;
    standard) echo "   DESIGN + TAD + SCHEMA + API + RULES + SESSION (6 docs)" ;;
    full)     echo "   DESIGN + TAD + SCHEMA + API + RULES + FEATURES + TASKS + TESTING + SESSION (9 docs)" ;;
esac
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
