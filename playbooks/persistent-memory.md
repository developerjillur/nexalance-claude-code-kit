# Playbook: Persistent Memory (MemPalace)

> **When Claude reads this:** setting up MemPalace, configuring hooks, or troubleshooting memory issues.

## The Problem

Claude Code has a ~200K token limit. Large projects hit this, forcing a new chat. When you start a new chat, all previous context is lost.

## Solution Layer 1: MemPalace MCP (Recommended)

MemPalace gives Claude Code persistent, searchable memory across sessions. All data stays local on your machine. Zero API cost.

### Install

```bash
pip install mempalace
claude plugin marketplace add milla-jovovich/mempalace
claude plugin install --scope user mempalace
```

### Or manual MCP config (`~/.claude.json`)

```json
{
  "mcpServers": {
    "mempalace": {
      "command": "python",
      "args": ["-m", "mempalace.mcp_server"],
      "env": {}
    }
  }
}
```

### MemPalace hooks (add to `~/.claude/settings.json`)

```json
{
  "hooks": {
    "Stop": [
      {
        "matcher": "",
        "hooks": [
          {
            "type": "command",
            "command": "python -m mempalace.hooks.save_hook"
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
            "command": "python -m mempalace.hooks.precompact_hook"
          }
        ]
      }
    ]
  }
}
```

## Memory Protocol for Claude Code (wing-isolated)

```
ON SESSION START:
  1. Read CLAUDE.md → extract PROJECT_WING value
  2. Set CURRENT_WING = that value
  3. Call mempalace_status → load memory context
  4. Call mempalace_search "[project name]" --wing CURRENT_WING
  5. Read docs/SESSION.md for task-level progress

DURING SESSION:
  - When making important decisions → mempalace_kg_add --wing CURRENT_WING
  - When completing features → mempalace_add_drawer --wing CURRENT_WING
  - Every 15 messages → automatic save via Stop hook
  - NEVER call MemPalace without --wing filter (prevents cross-project bleed)

ON SESSION END:
  1. mempalace_diary_write --wing CURRENT_WING → summarize what was accomplished
  2. mempalace_kg_add --wing CURRENT_WING → save new architectural decisions
  3. Update docs/SESSION.md → human-readable progress
  4. git commit all changes

ON NEW SESSION START (after context reset):
  1. mempalace_status → full context loads automatically
  2. mempalace_search "current sprint" --wing CURRENT_WING → what was I doing?
  3. Read docs/SESSION.md → exact task to resume
  4. Continue exactly where left off — ZERO context loss
```

## Wing Isolation Rules (CRITICAL)

```
- Every MemPalace operation MUST include --wing CURRENT_WING
- mempalace_search "query" --wing CURRENT_WING
- mempalace_add_drawer "content" --wing CURRENT_WING
- mempalace_kg_add fact --wing CURRENT_WING
- mempalace_diary_write summary --wing CURRENT_WING
- NEVER search without --wing (prevents cross-project bleed)
```

## Room Auto-Detection (save to correct room within wing)

| Working on | Room name |
|-----------|-----------|
| Auth, login, JWT | auth |
| Database, schema, migrations | database |
| API, controllers, routes | api |
| Frontend, UI, components | frontend |
| Payment, Stripe, billing | payments |
| Deployment, Docker, CI/CD | deployment |
| Tests, E2E, Playwright | testing |
| Business logic, rules | business-logic |
| Third-party APIs | integrations |
| Architecture decisions | architecture |

## Solution Layer 2: Session Handoff Document (Fallback)

If MemPalace is not installed, use the manual handoff system. `setup-project-wing.sh` already creates a basic `HANDOFF.md`.

**Before ending EVERY session, update `docs/HANDOFF.md` with:**

- Project overview (1-2 lines)
- Current state (Phase, last task, next task)
- Key architectural decisions made this session
- Build/run/test commands
- DO NOT RE-DO list (completed features)
- Resume instruction: which task to start next

**New session start:** User says: "Read docs/HANDOFF.md and resume"

---

## Layer 3: Graphify Codebase Index (optional, complementary)

For large codebases, **Graphify** indexes structure (classes, deps, call graph). It is a different layer than MemPalace:
- **MemPalace** = episodic memory (what we did, decisions, conversations)
- **Graphify** = semantic index (what the code IS)

See the Graphify section in CLAUDE.md core for usage rules.

---

*Back to CLAUDE.md core.*
