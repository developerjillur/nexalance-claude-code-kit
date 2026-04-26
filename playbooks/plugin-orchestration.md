# Playbook: Plugin Auto-Orchestration (Detailed)

> **When Claude reads this:** when in doubt about which plugin to use, when plugins seem to conflict, OR when first running a session and you want the full priority/conflict matrix.
> The CLAUDE.md core has the **compressed** version — read this only if the compressed routing isn't enough.

## How It Works

All plugins are pre-configured to trigger AUTOMATICALLY based on what you're doing. The user NEVER needs to type a plugin command. YOU detect the context and use the right plugin.

## Auto-Trigger Rules (follow these SILENTLY)

```
╔══════════════════════════════════════════════════════════════════════╗
║  CONTEXT DETECTED              →  AUTO-ACTION (do it, don't ask)    ║
╠══════════════════════════════════════════════════════════════════════╣
║                                                                      ║
║  SESSION STARTS                                                      ║
║  ├─ First message of session   → mempalace_status (load memory)     ║
║  ├─ Existing project detected  → mempalace_search + read SESSION.md ║
║  └─ New project detected       → Superpowers brainstorm flow        ║
║                                                                      ║
║  BUILDING FEATURES                                                   ║
║  ├─ Complex feature (multi-file)→ /feature-dev (7-phase auto)       ║
║  ├─ Simple task (single file)  → Direct implementation              ║
║  ├─ Frontend/UI work           → Read DESIGN.md FIRST → shadcn/ui   ║
║  ├─ New page/component         → Check ShadcnBlocks for matching    ║
║  │                               block before building from scratch  ║
║  └─ Planning/designing         → /superpowers:brainstorm            ║
║                                                                      ║
║  QUALITY CHECKS (risk-tiered — see CLAUDE.md core)                  ║
║  ├─ Routine feature            → Inline 5-question review (Haiku)   ║
║  ├─ Complex feature            → 1-agent thorough (Sonnet)          ║
║  ├─ Security-sensitive         → /code-review (5-agent parallel)    ║
║  ├─ Pre-PR / milestone         → /code-review (5-agent parallel)    ║
║  └─ After 5-agent review       → Self-rating + fix gaps             ║
║                                                                      ║
║  MEMORY & TRACKING                                                   ║
║  ├─ Every 3 tasks completed    → mempalace_add_drawer (auto-save)   ║
║  ├─ Architecture decision made → mempalace_kg_add (save as fact)    ║
║  ├─ Every task completed       → Update FEATURES.md + TASKS.md      ║
║  └─ Hook: every 15 messages    → MemPalace auto-save (via hook)     ║
║                                                                      ║
║  SESSION ENDING                                                      ║
║  ├─ User says "done/stop/bye"  → Session Exit Gate (auto-run)       ║
║  ├─ After Exit Gate            → mempalace_diary_write              ║
║  ├─ After diary write          → Update HANDOFF.md + SESSION.md     ║
║  └─ Hook: before /compact      → MemPalace emergency save (auto)    ║
║                                                                      ║
║  BROWSER AUTOMATION                                                  ║
║  ├─ "Test this page/form/flow" → Playwright CLI (--headed)          ║
║  ├─ "Deploy via hosting panel" → Playwright CLI (--headed --persist)║
║  ├─ "Check console errors"     → Chrome DevTools MCP                ║
║  ├─ "Which API call failing?"  → Chrome DevTools MCP                ║
║  ├─ "Screenshot all pages"     → Playwright CLI (saves to disk)     ║
║  ├─ "Login and do X on site"   → Playwright CLI (--persistent)      ║
║  └─ "Page performance check"   → Chrome DevTools MCP                ║
║                                                                      ║
╚══════════════════════════════════════════════════════════════════════╝
```

## IMPORTANT BEHAVIOR

```
DO:
  ✅ Use plugins silently — the user should just see great results
  ✅ Fall back to manual approach if a plugin isn't installed
  ✅ Read DESIGN.md BEFORE any frontend work (primary design guidance)
  ✅ Use frontend-design skill for creative direction (supplementary)
  ✅ Run review proportional to risk (see core, not always 5-agent)
  ✅ Save to MemPalace automatically — user doesn't need to ask

DON'T:
  ❌ Ask "should I use /feature-dev?" — just use it
  ❌ Say "I'm now invoking the code-review plugin" — just do the review
  ❌ Ask "should I save to MemPalace?" — always save (with --wing)
  ❌ List plugin commands to the user — they don't need to know
  ❌ Announce MemPalace operations — they're background tasks
  ❌ Always run 5-agent review — only when risk-tier says so
```

## Plugin Priority (when plugins could conflict)

```
RULE: When two plugins try to manage the same workflow, follow this priority:

1. Superpowers brainstorm → for NEW ideas/features (design phase)
2. /feature-dev → for IMPLEMENTING a known feature (build phase)
3. /code-review → for REVIEWING completed work (quality phase, risk-tiered)

CONFLICT SCENARIOS:
  "Build a new auth system"
    → Is it new/undefined? → Superpowers brainstorm first → then /feature-dev
    → Is it clearly defined in PRD? → Skip brainstorm → /feature-dev directly

  "Review and improve the auth code"
    → /code-review first → then fix based on findings

  User says "plan this feature" + Superpowers auto-triggers:
    → Let Superpowers handle it (it's designed for planning)
    → Do NOT also run /feature-dev planning phase

  User says "build this feature" + /feature-dev auto-triggers:
    → Let /feature-dev handle it (it's designed for building)
    → Do NOT also run Superpowers brainstorm

SIMPLE RULE: Planning? → Superpowers. Building? → /feature-dev.
             Reviewing? → risk-tiered (see core).
             Never run two workflow plugins simultaneously.
```

## Token/Cost Awareness

```
After EVERY session, include in session summary:
  - Estimated tokens used this session
  - Heavy operations: [list any Playwright snapshots, large file reads]
  - Context health: [light/medium/heavy]

Tips to save tokens (already baked into v4.4 LITE):
  - Use playwright-cli (not MCP) → saves ~87K tokens per browser task
  - Read specific doc sections (not full files) → saves ~5-10K per read
  - /compact after Phase 0 doc generation → frees ~30-40K tokens
  - Disable unused MCP servers → each saves ~5-15K tokens
  - Use mempalace_search with --wing filter → faster, less data returned
  - Lazy-load playbooks ONLY when relevant — never read all upfront
  - Inline self-review (not 7-category re-pass) → saves 3-5K per task
  - Risk-tiered review (not always 5-agent) → saves 15-20K per routine task
  - Dispatch cheap tasks to Haiku subagents → saves ~30% on auxiliary ops
```

## Plugin Availability (check ONCE per session, silently)

```
On first interaction:
  1. mempalace_status → available? (store result)
  2. /superpowers: exists? (store result)
  3. /code-review exists? (store result)
  4. /feature-dev exists? (store result)

If ALL available → work at full power, silently
If SOME missing → work with what's available, inform user ONCE:
  "For optimal workflow, install missing plugins:
   [only list what's missing with install command]"
If NONE available → fall back to manual CLAUDE.md workflow (still works)
```

## Installation (if needed — run setup script ONCE per machine)

```bash
bash setup-nexalance.sh
```

Or manually:

```bash
# Superpowers
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace

# MemPalace
pip install mempalace
claude plugin install --scope user mempalace

# Anthropic Official
/plugin install code-review@claude-plugins-official
/plugin install feature-dev@claude-plugins-official
/plugin install frontend-design@claude-plugins-official

# Playwright CLI (browser automation — 4x token efficient vs MCP)
npm install -g @playwright/cli
npx playwright install chromium

# Chrome DevTools MCP (browser debugging)
claude mcp add chrome-devtools --scope user -- npx chrome-devtools-mcp@latest

# Design Quality Tools
claude plugin add github:masonjames/Shadcnblocks-Skill
npx skills add vercel-labs/agent-skills

# Optional: Graphify (codebase knowledge graph)
bash setup-graphify.sh
```

---

*Back to CLAUDE.md core.*
