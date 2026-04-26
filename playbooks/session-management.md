# Playbook: Session Management & Exit Gate

> **When Claude reads this:** session start, session middle (every 3 tasks), session end, OR when context feels heavy.

## Session START

```
1. MemPalace Wake-up (if installed):
   → Call mempalace_status → loads memory context (only ~170 tokens)
   → Call mempalace_search "[project name]" --wing CURRENT_WING → recall project state
   → Call mempalace_search "current sprint" --wing CURRENT_WING → what was being worked on

2. Read docs/SESSION.md (this tells you exactly where to resume)
3. Read docs/FEATURES.md (Full tier only — know overall progress)
4. Announce:
   "📍 Resuming: Phase [N], Task [T-XXX]
    📈 Progress: [X/Y] features done ([Z]%)
    🧠 Memory: [loaded from MemPalace / loaded from SESSION.md]
    ⏭️ Next: [task description]"
5. Begin work on the next incomplete task
```

## Session MIDDLE (every 3 tasks)

```
1. Update SESSION.md with progress
2. Update FEATURES.md if any feature completed (Full tier)
3. MemPalace save (if installed):
   → mempalace_add_drawer --wing CURRENT_WING: save completed task details
   → mempalace_kg_add --wing CURRENT_WING: save any architectural decisions made
4. If context feels heavy → run /compact
5. git commit progress
```

## Session END

```
⚠️ BEFORE writing any summary, run the SESSION EXIT GATE (below).
Only AFTER the Exit Gate passes:

1. Update SESSION.md:
   - Tasks completed this session (with self-review scores)
   - Current task in progress (if any)
   - Blockers encountered
   - Next 3 tasks to do
   - Files modified
   - Build/test status
2. Update HANDOFF.md (if exists) with latest state
3. MemPalace session save (if installed):
   → mempalace_diary_write --wing CURRENT_WING:
     "Session summary: completed T-XXX to T-YYY, Phase N is Z% complete.
      Key decisions: [list]. Blockers: [list]. Next: T-ZZZ [description]."
   → mempalace_kg_add --wing CURRENT_WING: save any new facts/decisions as triples
     Example: ("auth_system", "uses", "JWT with refresh tokens")
     Example: ("users_table", "has_column", "deleted_at for soft delete")
4. git commit -m "progress: [session summary]"
5. Announce:
   "✅ Session complete. [N] tasks done. Avg quality: [X/10]
    📈 Phase [X]: [Y]% complete
    🧠 Memory: [saved to MemPalace / saved to SESSION.md + HANDOFF.md]
    🚪 Exit Gate: [PASSED/issues noted]
    ⏭️ Next session starts with: [T-XXX description]"
```

---

## 🚪 SESSION EXIT GATE

### Rule: NEVER end a session without running the Exit Gate.

Before writing any session summary or saying "session complete", you MUST:

### Exit Gate Checklist

```
STEP 1: CODEBASE REVIEW
  □ Read the files modified in this session
  □ Check for:
    - Incomplete functions (stubbed, TODO, placeholder)
    - Unused imports
    - Console.log statements (should be proper logging)
    - Hardcoded values
    - Missing error handling
    - TypeScript 'any' types
    - Missing input validation

STEP 2: VALIDITY CHECK
  □ Does the project build without errors?
    Run: npm run build (or equivalent)
  □ Does the linter pass?
    Run: npm run lint (or equivalent)
  □ Are there TypeScript errors?
    Run: npx tsc --noEmit (or equivalent)

STEP 3: RUN TESTS
  □ Run all existing tests
  □ Report: "X passed, Y failed, Z skipped"
  □ If any fail → try to fix before ending session
  □ If can't fix → document in SESSION.md as blocker

STEP 4: INTEGRATION QUICK-CHECK (using Playwright CLI + Chrome DevTools)
  □ Start the dev server (if possible)
  □ Playwright CLI: navigate to main pages (--headed --persistent)
    → playwright-cli navigate http://localhost:3000 --headed --persistent
    → playwright-cli snapshot → verify page renders with real data
  □ Chrome DevTools: check browser console for errors
    → No console.error entries
    → No failed network requests to /api/*
  □ Verify features completed this session actually work:
    → playwright-cli fill + click → test main user flow
    → playwright-cli snapshot → verify result
  □ playwright-cli screenshot → save visual proof

STEP 5: UPDATE SESSION.md
  Only AFTER passing steps 1-4, write the session summary.
```

### Exit Gate Report Format

```
🚪 SESSION EXIT GATE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Codebase Review:  [CLEAN / X issues found]
Build Status:     [PASS / FAIL]
Lint Status:      [PASS / X warnings]
Test Results:     [X passed, Y failed]
Integration:      [VERIFIED / NOT CHECKED]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Session Summary:  [N] tasks completed
Overall Quality:  [avg self-review score]/10
Ready for next:   T-XXX — [description]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## Context Emergency Protocol

If you notice:
- Responses getting shorter or less detailed
- Forgetting what was discussed earlier
- Making mistakes on things you already knew

DO THIS:

```
1. STOP current work
2. MemPalace emergency save (if installed):
   → mempalace_diary_write --wing CURRENT_WING: emergency context dump
   → mempalace_kg_add --wing CURRENT_WING: save all current state as facts
3. Update SESSION.md with DETAILED current state
4. Update HANDOFF.md with full context
5. git commit all changes
6. Tell user: "Context is getting heavy. Please run /compact or start a new session.
   I've saved everything to MemPalace + SESSION.md + HANDOFF.md.
   New session will resume exactly where I left off — zero context loss."
```

---

## Recovery Protocol (when context lost or you're confused)

```
1. MemPalace Recovery (if installed):
   → mempalace_status → load memory context
   → mempalace_search "[project name]" --wing CURRENT_WING → recall project state
   → mempalace_search "last session" --wing CURRENT_WING → what was done recently

2. File Recovery:
   → Read docs/SESSION.md → tells you EXACTLY where you are
   → Read docs/HANDOFF.md → full context for new sessions
   → Read docs/TASKS.md (Full tier) → find first incomplete task (look for [ ])
   → Read the SPECIFIC section of the relevant doc for that task

3. Resume work from where you left off

DO NOT: Read all docs at once (wastes context)
DO NOT: Start over from scratch
DO NOT: Guess — MemPalace + docs have the answers
```

---

*Back to CLAUDE.md core. For MemPalace setup details, see `playbooks/persistent-memory.md`.*
