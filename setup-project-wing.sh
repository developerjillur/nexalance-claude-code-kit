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

# Scaffold the LLM Wiki layer (Karpathy pattern, fully automatic)
mkdir -p \
    docs/wiki/raw/{discussions,prompts,articles,interviews,inbox} \
    docs/wiki/synthesized/_entities
echo "✅ Created docs/wiki/ (raw + synthesized + LLM Wiki layer)"

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
    cp "$KIT_DIR/hooks/wiki-ingest.py"      .claude/hooks/ 2>/dev/null
    chmod +x .claude/hooks/*.sh .claude/hooks/*.py 2>/dev/null
    HOOKS_INSTALLED=1
    echo "✅ v4.4 LITE hooks installed to .claude/hooks/ (4 scripts)"
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
    ],
    "SessionStart": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "PY_BIN_PLACEHOLDER .claude/hooks/wiki-ingest.py 2>>docs/wiki/.ingest.log || true"
          }
        ]
      }
    ],
    "SessionEnd": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "PY_BIN_PLACEHOLDER .claude/hooks/wiki-ingest.py 2>>docs/wiki/.ingest.log || true"
          }
        ]
      }
    ]
  }
}
SETTINGS
    echo "✅ Hooks wired into .claude/settings.json (MemPalace + playbook-tracker + cache-warn + reset-counter + wiki-ingest)"
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

# LLM Wiki — auto-ingested raw transcripts may contain secrets / PII.
# Synthesized pages, articles, prompts, log.md, index.md ARE committed.
docs/wiki/raw/discussions/
docs/wiki/raw/interviews/
docs/wiki/.ingest-manifest.json
docs/wiki/.synthesis-pending
docs/wiki/.ingest.log
GITIGNORE
    git add -A
    git commit -m "chore: initialize $PROJECT_NAME workspace with NexaLance orchestrator"
    echo "✅ Git initialized"
else
    echo "⚠️  Git already initialized"
fi

# ─── Scaffold LLM Wiki templates (v4.4 LITE only — playbook lives there) ─
# These files are version-controlled and form the wiki's spine.
# We only write them when the v4.4 LITE template is in use (it ships
# the playbooks/llm-wiki.md that drives the workflow). For v4.3-legacy
# projects, we skip the wiki layer entirely.
if [ "$TEMPLATE_VERSION" = "v4.4-LITE" ] && [ ! -f "docs/wiki/CLAUDE.md" ]; then
    cat > docs/wiki/CLAUDE.md << WIKICLAUDE
# Wiki Schema — $PROJECT_NAME

This file is the schema for the project's LLM Wiki (Karpathy pattern).
Read this when you operate on \`docs/wiki/\` — it defines conventions
that keep the wiki disciplined and queryable.

For the full workflow (ingest / query / lint), see
\`playbooks/llm-wiki.md\` in the kit.

## Layer purpose

\`docs/wiki/\` is the **domain knowledge** layer for this project.
It holds: research, references, decisions, glossaries, prompt
patterns, and synthesized summaries of past Claude Code sessions.
It is distinct from MemPalace (episodic), Graphify (code semantic),
and SESSION.md (current state).

## Folder structure

\`\`\`
docs/wiki/
├── CLAUDE.md            ← this file (schema)
├── index.md             ← catalog of every page (you maintain it)
├── log.md               ← append-only audit (you + hook write here)
├── raw/                 ← immutable sources, never edit content
│   ├── discussions/     ← auto-ingested session transcripts (gitignored)
│   ├── prompts/         ← raw prompts (frontmatter: worked/failed)
│   ├── articles/        ← clipped articles, papers, screenshots
│   ├── interviews/      ← customer/stakeholder interviews (gitignored)
│   └── inbox/           ← unsorted drops; triage on demand
└── synthesized/         ← LLM-generated wiki pages (committed)
    ├── domain-glossary.md
    ├── decision-log.md
    ├── prompt-patterns.md
    └── _entities/       ← per-entity pages
\`\`\`

## Frontmatter convention

Every page in \`synthesized/\` should have:

\`\`\`markdown
---
title: <human-readable title>
type: <entity | concept | decision | reference | synthesis>
tags: [<topic>, <topic>]
last_updated: YYYY-MM-DD
sources:
  - ../raw/.../<file>.md
---
\`\`\`

## Naming convention

- \`synthesized/_entities/<lowercase-hyphenated>.md\` — one file per entity
- \`synthesized/<topic>.md\` — single-page topics
- \`raw/discussions/YYYY-MM-DD-<short-id>.md\` — auto-named by hook
- \`raw/{prompts,articles,interviews}/YYYY-MM-DD-<slug>.md\`

## Workflow triggers

| When                                                | What you (Claude) do                                |
|-----------------------------------------------------|------------------------------------------------------|
| \`.synthesis-pending\` exists                        | Process pending raw → update synthesized + index    |
| User asks a domain/recall question                  | Query: read \`index.md\` first, drill 2–4 pages     |
| ≥5 unprocessed entries                              | Run lint pass (orphans, contradictions, duplicates) |
| User drops a file in \`raw/inbox/\`                  | Triage: move to right folder + update synthesized   |

Full workflow details: \`playbooks/llm-wiki.md\`.

## What is auto vs. manual

- **Hook (auto):** JSONL session transcripts → \`raw/discussions/\` markdown
- **You (semi-auto):** synthesis from raw → wiki pages, index updates, lint
- **User (manual):** dropping curated articles/prompts/interviews into \`raw/\`

The user should never have to run anything. Hooks handle plumbing.
You handle thinking.
WIKICLAUDE
    echo "✅ docs/wiki/CLAUDE.md schema written"
fi

if [ "$TEMPLATE_VERSION" = "v4.4-LITE" ] && [ ! -f "docs/wiki/index.md" ]; then
    cat > docs/wiki/index.md << WIKIINDEX
# Wiki Index — $PROJECT_NAME

Catalog of every page in this wiki. Auto-curated by Claude.
Read this **first** when answering domain/recall questions.

## Decisions
*(populated as decisions are recorded)*

## Entities
*(populated as concepts/people/products are filed)*

## References
*(populated as articles/papers are ingested)*

## Sessions
*(populated as Claude Code sessions are auto-ingested)*

---

> Format: \`[Page Title](path/to/page.md) — one-line summary.\`
> Sort within each section by relevance, not date.
WIKIINDEX
    echo "✅ docs/wiki/index.md scaffolded"
fi

if [ "$TEMPLATE_VERSION" = "v4.4-LITE" ] && [ ! -f "docs/wiki/log.md" ]; then
    cat > docs/wiki/log.md << WIKILOG
# Wiki Log — $PROJECT_NAME

Append-only chronological record of ingest, synthesize, query, and lint
operations. Hook entries start with \`## [YYYY-MM-DD HH:MM] ingest |\`,
synthesis entries with \`## [YYYY-MM-DD HH:MM] synthesize |\`, etc.

---

## [$(date '+%Y-%m-%d %H:%M')] init | wiki scaffolded for $PROJECT_NAME (tier: $TIER)

WIKILOG
    echo "✅ docs/wiki/log.md initialized"
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

# ─── Backfill the wiki: ingest any pre-existing Claude Code sessions ───
# Runs the wiki-ingest hook once at end of setup so the project starts
# with all prior session transcripts already converted to markdown.
# This is what makes the wiki "automatic from minute zero" — no need to
# wait for the next SessionStart to populate raw/discussions/.
if [ "$TEMPLATE_VERSION" = "v4.4-LITE" ] && [ -f .claude/hooks/wiki-ingest.py ]; then
    BACKFILL_OUT=$(CLAUDE_PROJECT_DIR="$(pwd)" "$PY_BIN" .claude/hooks/wiki-ingest.py 2>&1 || true)
    INGESTED=$(ls docs/wiki/raw/discussions/*.md 2>/dev/null | wc -l | tr -d ' ')
    if [ "$INGESTED" -gt 0 ]; then
        echo "✅ Wiki backfill: ingested $INGESTED prior session(s) into docs/wiki/raw/discussions/"
    else
        echo "✅ Wiki ready (no prior Claude Code sessions for this project to backfill)"
    fi
fi

echo ""
echo "═══════════════════════════════════════════════"
echo "🎉 DONE! Project workspace ready."
echo "═══════════════════════════════════════════════"
echo ""
echo "📁 Your workspace:"
echo "   CLAUDE.md          ← PROJECT_WING: \"$WING\" | TIER: \"$TIER\" ($TEMPLATE_VERSION)"
echo "   .mcp.json          ← MemPalace + TaskMaster"
echo "   .claude/settings.json ← Hooks: MemPalace$([ "$HOOKS_INSTALLED" = "1" ] && echo " + playbook-tracker + cache-warn + reset-counter + wiki-ingest")"
if [ "$HOOKS_INSTALLED" = "1" ]; then
echo "   .claude/hooks/     ← v4.4 LITE hooks (4 scripts including wiki-ingest)"
fi
echo "   .claude/commands/  ← Wing-aware orchestrator"
echo "   docs/SESSION.md    ← Session tracker$([ "$TIER" != "full" ] && echo " (with Feature Tracker)")"
echo "   docs/HANDOFF.md    ← Session handoff"
if [ "$TEMPLATE_VERSION" = "v4.4-LITE" ]; then
echo "   docs/wiki/         ← LLM Wiki (auto-ingest of sessions, synthesized knowledge)"
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
