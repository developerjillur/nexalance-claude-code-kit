# Playbook: Feature Implementation Workflow

> **When Claude reads this:** triggered when starting any new feature or task. Read this BEFORE coding.

For EACH feature, follow this EXACT sequence.

```
┌─ 0. PLUGIN-DRIVEN DEVELOPMENT (preferred when available)
│   IF Superpowers + feature-dev are available:
│
│   For COMPLEX features (new module, multi-file, API + UI):
│     → /feature-dev [feature description]
│     → 7-phase workflow runs automatically:
│       Phase 1: Requirements gathering from docs
│       Phase 2: Codebase exploration (parallel agents study architecture)
│       Phase 3: Architecture design
│       Phase 4: Implementation
│       Phase 5: Testing
│       Phase 6: Code review
│       Phase 7: Documentation
│     → After /feature-dev → run review per "Risk-Tiered Review" in CLAUDE.md core
│     → Then continue to step 4 (FULL CHAIN VERIFICATION) below
│
│   For SIMPLE features (single file change, config, small fix):
│     → Skip /feature-dev, follow manual steps 1-3 below
│
│   For FRONTEND-HEAVY features (new pages, UI components):
│     → Read docs/DESIGN.md FIRST (colors, fonts, spacing, tokens)
│     → Check ShadcnBlocks for matching pre-built block (hero, dashboard, pricing...)
│     → Use shadcn/ui components — NEVER build from scratch
│     → DESIGN.md is primary reference, frontend-design skill supplements
│     → After building → Playwright CLI screenshot → verify quality
│     → If looks "generic AI" → redo with more DESIGN.md specifics
│
├─ 1. CONTEXT LOADING (minimal reads — for manual implementation)
│   Read ONLY from the relevant docs:
│   - Feature row → FEATURES.md (Full tier) OR SESSION.md → Feature Tracker (Lite/Standard tier)
│   - TASKS.md: tasks for this feature (Full tier; Lite/Standard tracks inline in SESSION.md)
│   - RULES.md: only business rules referenced by this feature (by BR-ID, Standard/Full)
│   - SCHEMA.md: only tables needed for this feature
│   - API.md: only endpoints for this feature (Standard/Full tier)
│   If Lite tier → API.md/RULES.md/TAD.md may not exist; work from PRD + SESSION.md + DESIGN.md + SCHEMA.md
│
├─ 2. BACKEND FIRST
│   a. Create/update database migration
│   b. Create entity/model matching SCHEMA.md
│   c. Create repository (data access layer)
│   d. Create service (business logic from RULES.md)
│   e. Create DTO with validation (from API.md request spec)
│   f. Create controller/route (from API.md endpoint spec)
│   g. Write & run API tests
│   h. Verify: curl/httpie the endpoint → get REAL data from DB
│
├─ 3. FRONTEND (with Design System enforcement)
│   a. Read docs/DESIGN.md FIRST — load palette, spacing, component tokens
│   b. Use shadcn/ui components — NEVER build buttons/inputs/cards from scratch
│   c. Create API client function (typed request + response)
│   d. Create component following DESIGN.md specifications:
│      → Colors: ONLY from DESIGN.md palette (no random hex)
│      → Spacing: ONLY from 8px grid system (no random padding)
│      → Typography: ONLY from defined scale (no random font sizes)
│      → Borders: --radius-md for buttons, --radius-lg for cards
│      → Shadows: defined shadow tokens (not arbitrary values)
│   e. Every component MUST have:
│      → Loading state (skeleton matching component shape)
│      → Empty state (illustration + message + action button)
│      → Error state (error message + retry button)
│      → Success state (real data from API)
│   f. Connect component to real API (no hardcoded data)
│   g. Add form validation matching backend validation
│   h. Responsive check: 375px, 768px, 1024px, 1440px
│   i. Playwright CLI screenshot → compare with design intent:
│      → playwright-cli navigate http://localhost:3000/[page] --headed
│      → playwright-cli screenshot --output .screenshots/reviews/$(date +%Y-%m-%d)_[page]-review.png
│      → Review: does it look professional? Or "generic AI"?
│      → If generic → redo with DESIGN.md specifics
│
├─ 4. FULL CHAIN VERIFICATION
│   Verify this chain works end-to-end:
│   User Action → UI → API Call → Service → DB → Response → UI Update
│   If ANY link breaks → fix before marking done
│
├─ 5. CODE REVIEW (risk-tiered — see CLAUDE.md core "Review Routing")
│   Routine feature → 1-agent inline review (Haiku)
│   Complex feature → 1-agent thorough (Sonnet)
│   Security-sensitive (auth/payments/PII/uploads/RBAC) → /code-review (5-agent)
│   Pre-PR milestone → /code-review (5-agent)
│   Fix ALL issues found before proceeding.
│
├─ 6. UPDATE TRACKING + MEMORY
│   a. Feature progress:
│      → Full tier: update FEATURES.md row (status + all checkmark columns)
│      → Lite/Standard tier: update SESSION.md → Feature Tracker row (status, files, tested, working)
│   b. TASKS.md: mark [x] on completed tasks (Full tier; Lite/Standard logs inline in SESSION.md)
│   c. SESSION.md: update Current State + Session History (every 3 tasks — all tiers)
│   d. mempalace_add_drawer --wing CURRENT_WING: save feature completion details
│   e. git commit -m "feat(F-XXX): [description] — implemented, tested, reviewed"
│
├─ 7. GIT BRANCH MANAGEMENT
│   For each NEW feature (not small fixes):
│   a. Before starting: git checkout -b feature/F-XXX-description
│   b. Work on this branch
│   c. After review passes: git checkout develop && git merge feature/F-XXX-description
│   d. Delete branch: git branch -d feature/F-XXX-description
│   For small fixes/tasks: commit directly to develop branch
│
└─ 8. NEXT
    Move to next task. If Phase complete → run Integration Checkpoint below.
```

---

## Phase-Based Development

### Phase Flow:
```
Phase 1: Foundation (Auth + DB + Project skeleton)
Phase 2: Core Features (Main business logic, CRUD, primary flows)
Phase 3: Advanced Features (AI, integrations, real-time, reports)
Phase 4: Polish (UI/UX, performance, error handling edge cases)
Phase 5: Deployment Ready (Docker, CI/CD, monitoring, production config)
```

### Rules:
- Phase N must be 100% done before Phase N+1
- "100% done" = all tasks [x] + all tests pass + integration checkpoint PASS
- If integration checkpoint FAILS → fix ALL issues before proceeding

### Integration Checkpoint (run after EVERY phase):

```markdown
## Phase [N] Checkpoint — [Date]

### Automated Checks:
- [ ] All tests pass (unit + integration + e2e)
- [ ] No TypeScript/linter errors
- [ ] No console.error in browser
- [ ] No unhandled promise rejections

### Manual Flow Checks:
- [ ] Complete user journey works end-to-end with REAL data
- [ ] All forms validate correctly (submit valid + invalid data)
- [ ] Error states display meaningful messages
- [ ] Loading states appear during data fetch
- [ ] Empty states show when no data exists
- [ ] Page refresh preserves state (no data loss)
- [ ] Unauthorized access properly blocked
- [ ] All CRUD operations persist to database

### Database Verification:
- [ ] Data created through UI exists in database
- [ ] Data updated through UI reflects in database
- [ ] Data deleted through UI removed from database
- [ ] No orphan records
- [ ] Foreign key constraints working

### Result: PASS ✅ / FAIL ❌
If FAIL → list specific issues → fix ALL → re-run checkpoint
```

---

*Back to CLAUDE.md core. For Action-Level Testing details, see `playbooks/testing.md`. For browser automation, see `playbooks/browser-automation.md`. For full self-review template, see `playbooks/self-review-full.md`.*
