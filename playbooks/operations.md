# Playbook: Operations (File Routing + Project Structure + Deployment + Rollback + Conflict Resolution)

> **When Claude reads this:** saving generated artifacts, organizing folders, deploying, rolling back, or resolving PRD/rule conflicts.

## 📁 FILE OUTPUT ROUTING

### Rule: EVERY generated file has a designated home. NEVER dump files in project root.

```
╔═══════════════════════════════════════════════════════════════════════╗
║  WHAT YOU'RE CREATING              → WHERE TO SAVE IT                ║
╠═══════════════════════════════════════════════════════════════════════╣
║                                                                       ║
║  CODE REVIEW REPORTS                                                  ║
║  ├─ /code-review output            → docs/reviews/review-FXXX.md     ║
║  ├─ Self-review report (escalated) → docs/reviews/self-review-TXXX.md║
║  ├─ Phase checkpoint report        → docs/reviews/checkpoint-P1.md   ║
║  └─ Security audit                 → docs/reviews/security-audit.md  ║
║                                                                       ║
║  ANALYSIS & RESEARCH                                                  ║
║  ├─ Tech stack comparison          → docs/analysis/tech-stack.md     ║
║  ├─ Architecture decision          → docs/analysis/arch-TOPIC.md     ║
║  ├─ Performance audit              → docs/analysis/perf-audit.md     ║
║  ├─ Dependency analysis            → docs/analysis/deps-audit.md     ║
║  └─ Any research/investigation     → docs/analysis/research-TOPIC.md ║
║                                                                       ║
║  PLANS & BRAINSTORMS                                                  ║
║  ├─ Superpowers brainstorm output  → docs/plans/brainstorm-TOPIC.md  ║
║  ├─ Superpowers write-plan output  → docs/plans/plan-FEATURE.md      ║
║  ├─ Phase implementation plan      → docs/plans/plan-phase-N.md      ║
║  ├─ Feature spec/design            → docs/plans/spec-FXXX.md         ║
║  └─ Migration/refactor plan        → docs/plans/migration-TOPIC.md   ║
║                                                                       ║
║  SCREENSHOTS (Playwright CLI)                                         ║
║  ├─ E2E test screenshots           → .screenshots/tests/             ║
║  ├─ Design review screenshots      → .screenshots/reviews/           ║
║  ├─ Deployment proof               → .screenshots/deployments/       ║
║  └─ Bug evidence                   → .screenshots/bugs/              ║
║                                                                       ║
║  PROJECT DOCS (Phase 0)                                               ║
║  ├─ All Phase 0 generated docs     → docs/ (root level)              ║
║  ├─ PRD, DESIGN, TAD, SCHEMA, etc. → docs/                           ║
║  └─ SESSION, HANDOFF, CONFLICTS    → docs/                           ║
║                                                                       ║
║  GRAPHIFY (optional, if installed)                                    ║
║  ├─ Knowledge graph artifacts      → graphify-out/                   ║
║  └─ Cache (gitignored)             → graphify-out/cache/             ║
║                                                                       ║
╚═══════════════════════════════════════════════════════════════════════╝
```

### File Naming Convention

```
Pattern: type-subject.md

Reviews:   review-F001-auth.md, review-phase1-checkpoint.md
Analysis:  analysis-tech-stack.md, analysis-auth-approach.md
Plans:     plan-phase1.md, brainstorm-ai-matching.md, spec-F005-dashboard.md
Screenshots: 2026-04-14_F001-login-success.png

RULES:
  ✅ Lowercase with hyphens (no spaces, no underscores in .md files)
  ✅ Include feature ID (FXXX) or phase number when applicable
  ✅ Screenshots: date prefix YYYY-MM-DD_ always
  ✅ Be descriptive (review-auth.md NOT review-1.md)
```

### Auto-Create Folders

```
Before saving ANY file to docs/reviews/, docs/analysis/, docs/plans/, or .screenshots/:
  → mkdir -p [target folder]
  → Then save the file

On project init (setup-project-wing.sh already does this):
  → mkdir -p docs/{reviews,analysis,plans}
  → mkdir -p .screenshots/{tests,reviews,deployments,bugs}
```

### .gitignore Rules

```
.screenshots/          # Don't commit screenshots (large binary files)
.playwright-cli/       # Playwright CLI default output folder
*.png                  # In case screenshots leak to other folders
graphify-out/cache/    # Graphify SHA256 cache

# DO commit:
# docs/reviews/*.md       ← project documentation
# docs/analysis/*.md      ← decision records
# docs/plans/*.md         ← implementation plans
# graphify-out/graph.json ← optional, for shared codebase context
# graphify-out/GRAPH_REPORT.md
```

---

## 🗂️ PROJECT STRUCTURE

```
project-root/
├── CLAUDE.md                ← THIS FILE (v4.4 LITE)
├── README.md                ← Setup + run instructions
├── .env.example
├── .gitignore
├── docker-compose.yml       ← Phase 5
├── Dockerfile               ← Phase 5
│
├── docs/                    ← ALL project documentation
│   ├── PRD.md               ← YOUR Product Requirements Document
│   ├── DESIGN.md            ← Design System (auto-generated, all tiers)
│   ├── TAD.md               ← Technical Architecture (Standard/Full tier)
│   ├── SCHEMA.md            ← Database Schema (all tiers)
│   ├── API.md               ← API Specification (Standard/Full tier)
│   ├── RULES.md             ← Business Rules (Standard/Full tier)
│   ├── FEATURES.md          ← Feature Registry (Full tier)
│   ├── TASKS.md             ← Task Breakdown (Full tier)
│   ├── TESTING.md           ← Test Scenarios (Full tier)
│   ├── SESSION.md           ← Session State (all tiers)
│   ├── HANDOFF.md           ← Session Handoff (all tiers)
│   ├── CONFLICTS.md         ← PRD/Rule conflicts log (created when needed)
│   │
│   ├── reviews/             ← Code review reports + escalated self-reviews
│   ├── analysis/            ← Technical analysis + research + decisions
│   └── plans/               ← Implementation plans + brainstorm outputs
│
├── .screenshots/            ← Playwright CLI screenshots
│   ├── tests/
│   ├── reviews/
│   ├── deployments/
│   └── bugs/
│
├── graphify-out/            ← Optional: Graphify knowledge graph
│   ├── graph.json
│   ├── graph.html
│   ├── GRAPH_REPORT.md
│   └── cache/               ← gitignored
│
├── src/                     ← Application source
├── tests/                   ← Mirrors src/ structure
└── seed/                    ← DB seed/fixture data
```

### Folder Rules

```
SCREENSHOTS (.screenshots/):
  - ALL Playwright CLI screenshots go here
  - Naming: YYYY-MM-DD_description.png
  - Sub-folders by purpose
  - Add to .gitignore
  - Clean up old screenshots periodically

DOCS (docs/reviews/, docs/analysis/, docs/plans/):
  - All generated .md files go in appropriate sub-folder
  - Naming: type-subject.md
  - These ARE committed to git (they're documentation)

AUTO-CREATION:
  Claude Code creates these folders automatically on first use.
  If folder doesn't exist → mkdir -p → then save file.
```

---

## 🚀 DEPLOYMENT READINESS (Phase 5)

When all features are complete, before declaring "done":

```
### Production Checklist:
- [ ] Dockerfile created and builds successfully
- [ ] docker-compose.yml for local development
- [ ] .env.example has ALL required variables documented
- [ ] Database migrations run cleanly on fresh DB
- [ ] Seed data works (for demo/staging)
- [ ] All environment-specific configs externalized
- [ ] Error logging configured (not just console.log)
- [ ] Health check endpoint: GET /api/health → 200
- [ ] CORS configured for production domains
- [ ] Rate limiting configured
- [ ] README.md has: setup, run, test, deploy instructions
- [ ] No TODO comments left unresolved (or converted to GitHub issues)
- [ ] All tests pass in clean environment
- [ ] Build produces no warnings
```

---

## 🔙 ROLLBACK & FIX PROTOCOL

When something breaks that was previously working:

```
1. STOP — Do not continue building new features
2. IDENTIFY — Which commit introduced the break?
   → git log --oneline | check recent commits
3. ISOLATE — Is it a frontend, backend, or database issue?
   → Chrome DevTools MCP: check console + network for errors
4. FIX — Apply minimal fix to restore functionality
5. TEST — Run the test for the broken feature to confirm fix
   → playwright-cli: verify fix in browser (--headed)
6. REGRESSION TEST — Run ALL tests for the current Phase
7. RESUME — Only continue new work after all Phase tests pass
8. DOCUMENT — Add to SESSION.md: "Fixed regression in [feature]"

NEVER: Ignore a broken feature and move on
NEVER: Delete and rebuild from scratch (waste of work)
ALWAYS: Git commit the fix separately: "fix(F-XXX): [what broke and why]"
```

---

## ⚔️ CONFLICT RESOLUTION PROTOCOL

When you find contradictions or ambiguity:

### PRD Contradictions

```
If PRD says two conflicting things:
  1. STOP — do not guess or pick one randomly
  2. Document the conflict in docs/CONFLICTS.md:
     "CONFLICT-001: PRD Section 3 says max 10 items per order,
      but Section 7 says unlimited items. Which is correct?"
  3. Ask the user: "I found a conflict in the PRD: [describe].
     Which should I follow?"
  4. After resolution → update PRD + RULES.md + mempalace_kg_add
  5. Continue work
```

### Business Rule Conflicts

```
If two business rules contradict:
  BR-005: "Free shipping over $50"
  BR-012: "Shipping always $5.99"
  → Document in CONFLICTS.md
  → Ask user for clarification
  → Update RULES.md with resolved rule
```

### Tech Stack Decisions

```
If PRD doesn't specify tech stack or gives conflicting hints:
  1. Recommend based on project type (see below)
  2. Present 2-3 options with pros/cons
  3. Let user decide
  4. Save decision: mempalace_kg_add ("project", "tech_decision", "[choice] because [reason]")

Default recommendations:
  E-commerce → Next.js + Supabase (or WordPress + WooCommerce for budget)
  SaaS → Next.js + NestJS + PostgreSQL
  API-only → NestJS + PostgreSQL
  AI Platform → Next.js + Python + FastAPI
  WordPress → Kadence/Gutenberg (not Elementor)
  Mobile → React Native / Flutter
```

---

## 📊 PROGRESS REPORTING (after EVERY task completion)

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📊 TASK COMPLETE
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
✅ T-XXX: [task description]
📁 Files: [files created/modified]
🧪 Tests: [X passed, Y failed]
🌐 Browser: [N pages tested via Playwright CLI | or "N/A"]
🔗 Chain: DB [✅/❌] → API [✅/❌] → UI [✅/❌]
🔒 Security: Input validated [✅/❌] | Auth checked [✅/❌]
🎯 Actions Tested: [N] buttons | [N] forms | [N] error paths
🌿 Git: [branch name] | [commit hash]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔍 INLINE REVIEW: PASS / ESCALATED
  (If ESCALATED: see docs/reviews/ for full report)
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
📈 Phase [N]: [X/Y] tasks ([Z]%)
🎯 Overall: [A/B] features ([C]%)
💡 Context: [light/medium/heavy — suggest /compact if heavy]
⏭️ Next: T-XXX — [description]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

---

## 🏢 NexaLance Agency Standards

```
Code Style:     Project linter config (ESLint/Prettier for JS/TS, PSR-12 for PHP)
Git Commits:    type(scope): description — feat, fix, refactor, test, docs, chore
Branching:      main → develop → feature/F-XXX-description
Env Variables:  .env only, never hardcoded, .env.example committed
API Prefix:     /api/v1/
Response:       { success: bool, data: T | null, error: string | null, meta?: {} }
Timestamps:     UTC, ISO 8601
IDs:            UUID v4 (unless project requires auto-increment)
Soft Delete:    deleted_at column (never hard delete user data)
Logging:        Structured JSON logs (not console.log in production)
```

---

*Back to CLAUDE.md core.*
