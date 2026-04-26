# Playbook: Phase 0 — Project Initialization

> **When Claude reads this:** triggered by "Start project" / "Initialize" when no `docs/SESSION.md` shows progress.
> **Tier-aware:** generates only the docs your tier requires (see Project Tier in CLAUDE.md core).

Execute in this EXACT order. Complete each step fully before the next.

## Step 0.1 — Read & Analyze PRD (using Superpowers if available)

```
Action: Read docs/PRD.md completely

IF Superpowers plugin is available:
  → Run /superpowers:brainstorm with the PRD content
  → Let Superpowers ask clarifying questions and refine the spec
  → Review the refined spec in digestible chunks
  → Approve or adjust the design
  → Run /superpowers:write-plan to create implementation plan
  → This plan becomes the basis for TASKS.md (Standard/Full tier only)

IF Superpowers is NOT available (fallback):
  → Read PRD manually and print a 5-line summary:
    - Project name & type
    - Core features count
    - Target tech stack (if specified in PRD, else recommend)
    - Estimated complexity (Simple/Medium/Complex/Enterprise)
    - Estimated total tasks

IMPORTANT: Superpowers naturally enforces:
  - No jumping straight to code
  - Design review before implementation
  - TDD approach throughout
  - Subagent-driven development for each task
```

## Step 0.2 — Project Scaffolding

BEFORE generating docs, set up the actual project:

```
For Next.js/React projects:
  → npx create-next-app@latest . --typescript --tailwind --eslint --app --src-dir
  → Install core deps from PRD requirements
  → npx shadcn@latest init (choose default theme)
  → npx shadcn@latest add button card dialog input label table tabs toast
  → This gives Claude Code professional components out of the box

For NestJS projects:
  → npx @nestjs/cli new . --strict --package-manager npm
  → Install core deps
  → (No shadcn — backend only. DESIGN.md still generated for future frontend)

For Laravel projects:
  → composer create-project laravel/laravel .
  → Install core packages
  → For Blade UI: install Tailwind CSS + shadcn-like components manually

For WordPress projects:
  → Set up theme/plugin boilerplate
  → (DESIGN.md adapts to WordPress — colors/fonts for theme customizer)

Then for ALL projects:
  → Create docs/ directory
  → Create .env.example with placeholder keys
  → Create .gitignore (use appropriate template)
  → git init && git add -A && git commit -m "chore: initial project scaffold"
  → Create README.md with project name, description, setup instructions
```

## Step 0.3 — Generate Documents (Tier-Driven, Incremental)

Generate docs ONE AT A TIME. After each, briefly confirm it's complete before proceeding.

| Tier | Docs to generate | Feature progress lives in |
|------|------------------|---------------------------|
| **Lite** | DESIGN, SCHEMA, SESSION | `SESSION.md` → Feature Tracker section |
| **Standard** *(default)* | DESIGN, TAD, SCHEMA, API, RULES, SESSION | `SESSION.md` → Feature Tracker section |
| **Full** | DESIGN, TAD, SCHEMA, API, RULES, FEATURES, TASKS, TESTING, SESSION | Dedicated `FEATURES.md` |

**Tier-aware feature tracking — important:**
- Lite/Standard projects MUST include a `## Feature Tracker` section in their auto-generated `SESSION.md` (template below). This is non-negotiable; without it, feature progress drifts.
- Full projects use the dedicated `FEATURES.md` (the rich version with all checkmark columns).
- Both formats track: feature ID, name, status, files, and "working" verification flag.

If your tier is missing a doc and you later need it (e.g. Lite project starts needing TASKS.md), generate it on demand — do not regenerate the others.

---

### Doc 0: Design System (`docs/DESIGN.md`) — GENERATE FIRST (all tiers)

```markdown
# Design System — [Project Name]
# Auto-generated from PRD. Defines ALL visual decisions.

## Brand Analysis (extract from PRD)
- Project type: [SaaS / E-commerce / Dashboard / Landing / Blog / Admin]
- Target audience: [B2B / B2C / Internal / Developers]
- Tone: [Professional / Playful / Minimal / Bold / Corporate]
- Industry: [Tech / Health / Finance / Retail / Education]

## Color Palette (choose based on industry + tone)
### For Professional/Corporate:
- Primary: [Brand color from PRD, or derive from industry]
- Primary-hover: [10% darker than primary]
- Primary-light: [95% lighter than primary, for backgrounds]
- Secondary: [Complementary accent color]
- Background: #fafbfc (light gray, NOT pure white #fff)
- Surface: #ffffff (cards, modals)
- Text-primary: #0f172a (slate-900, NOT pure black)
- Text-secondary: #64748b (slate-500)
- Text-muted: #94a3b8 (slate-400)
- Border: #e2e8f0 (slate-200)
- Error: #ef4444 (red-500)
- Warning: #f59e0b (amber-500)
- Success: #22c55e (green-500)
- Info: #3b82f6 (blue-500)

### Dark Mode (if applicable):
- Background: #0f172a
- Surface: #1e293b
- Text-primary: #f8fafc
- Border: #334155

## Typography
- Font family: Inter (headings + body) — install: @fontsource/inter
- Fallback: system-ui, -apple-system, sans-serif
- Scale:
  | Element | Size | Weight | Line Height | Letter Spacing |
  |---------|------|--------|-------------|----------------|
  | h1 | 2.25rem (36px) | 800 | 1.2 | -0.025em |
  | h2 | 1.875rem (30px) | 700 | 1.25 | -0.02em |
  | h3 | 1.5rem (24px) | 600 | 1.3 | -0.015em |
  | h4 | 1.25rem (20px) | 600 | 1.35 | 0 |
  | body | 1rem (16px) | 400 | 1.6 | 0 |
  | small | 0.875rem (14px) | 400 | 1.5 | 0 |
  | caption | 0.75rem (12px) | 500 | 1.4 | 0.02em |

## Spacing (8px base grid — STRICT)
- 0.5: 2px | 1: 4px | 2: 8px | 3: 12px | 4: 16px
- 5: 20px | 6: 24px | 8: 32px | 10: 40px | 12: 48px
- 16: 64px | 20: 80px | 24: 96px

## Component Tokens
```css
/* Borders */
--radius-sm: 6px;    /* small elements: badges, chips */
--radius-md: 8px;    /* buttons, inputs */
--radius-lg: 12px;   /* cards, dialogs */
--radius-xl: 16px;   /* large containers */
--border-width: 1px;
--border-color: #e2e8f0;

/* Shadows */
--shadow-xs: 0 1px 2px rgba(0,0,0,0.05);
--shadow-sm: 0 1px 3px rgba(0,0,0,0.1), 0 1px 2px rgba(0,0,0,0.06);
--shadow-md: 0 4px 6px rgba(0,0,0,0.1), 0 2px 4px rgba(0,0,0,0.06);
--shadow-lg: 0 10px 15px rgba(0,0,0,0.1), 0 4px 6px rgba(0,0,0,0.05);

/* Transitions */
--transition-fast: 150ms ease;
--transition-base: 200ms ease;
--transition-slow: 300ms ease;
```

## Component Specifications
### Buttons
| Variant | Background | Text | Border | Hover |
|---------|-----------|------|--------|-------|
| Primary | primary | white | none | primary-hover |
| Secondary | transparent | primary | 1px primary | primary-light bg |
| Ghost | transparent | text-secondary | none | slate-100 bg |
| Destructive | red-500 | white | none | red-600 |
- Padding: py-2.5 px-5 (md), py-2 px-3 (sm), py-3 px-6 (lg)
- Font: font-medium, text-sm
- Radius: rounded-md (8px)
- Transition: all var(--transition-fast)
- Disabled: opacity-50, cursor-not-allowed

### Cards
- Background: white (surface)
- Border: 1px solid border-color
- Radius: rounded-xl (16px)
- Shadow: shadow-sm
- Padding: p-6
- Hover (if clickable): shadow-md, translateY(-1px)

### Inputs
- Height: h-10 (40px)
- Border: 1px solid border-color
- Radius: rounded-md
- Focus: ring-2 ring-primary/20, border-primary
- Placeholder: text-muted
- Error: border-red-500, ring-red-500/20
- Label: text-sm font-medium text-primary, mb-1.5

### Tables
- Header: bg-slate-50, text-sm font-medium text-secondary, uppercase tracking-wider
- Rows: border-b border-slate-100
- Hover: bg-slate-50
- Padding: px-6 py-4

### Navigation
- Height: h-16 (64px)
- Background: white/80 backdrop-blur-lg (sticky)
- Border-bottom: 1px solid border-color
- Logo: h-8
- Links: text-sm font-medium, hover:text-primary

## Layout System
- Max width: max-w-7xl (1280px)
- Page padding: px-4 sm:px-6 lg:px-8
- Section spacing: py-16 sm:py-20 lg:py-24
- Grid: gap-6 (24px)
- Sidebar width: w-64 (256px) or w-72 (288px)

## Page Templates (shadcn/ui blocks to use)
| Page | Recommended Blocks |
|------|-------------------|
| Landing | Hero + Features + Pricing + Testimonials + CTA + Footer |
| Dashboard | Sidebar + TopNav + Stats Cards + Data Table + Charts |
| Auth (Login) | Split layout: left=form, right=brand illustration |
| Settings | Vertical tabs + Form sections |
| List/Index | Search bar + Filters + Data table + Pagination |
| Detail | Breadcrumb + Header + Content + Related items |

## Design Quality Checklist (verify EVERY page)
- [ ] Colors match palette exactly (no random hex values)
- [ ] Typography follows scale (no random font sizes)
- [ ] Spacing follows 8px grid (no random padding)
- [ ] All interactive elements have hover + focus states
- [ ] All forms have labels, placeholders, error states
- [ ] Responsive: works at 375px, 768px, 1024px, 1440px
- [ ] Loading skeletons match component shapes
- [ ] Empty states have illustration + message + CTA
- [ ] Error pages are styled (404, 500), not browser defaults
- [ ] Consistent border-radius across all components
- [ ] Proper visual hierarchy (size, weight, color, spacing)
- [ ] No orphan text (single words on new lines)
- [ ] Sufficient contrast ratios (4.5:1 minimum for text)
```

IMPORTANT: Adapt this template based on what the PRD says about branding, target audience, and industry. If PRD specifies colors/fonts → use those. If PRD doesn't specify → derive the best choice from the project type.

---

### Doc 1: Technical Architecture (`docs/TAD.md`) — Standard/Full tier

```markdown
# Technical Architecture Document

## 1. Tech Stack
| Layer | Technology | Version | Justification |
|-------|-----------|---------|---------------|
| Frontend | ... | ... | ... |
| Backend | ... | ... | ... |
| Database | ... | ... | ... |
| Auth | ... | ... | ... |
| Hosting | ... | ... | ... |

## 2. Architecture Pattern
[Monolith / Microservice / Serverless / Hybrid]
Layer diagram: Controller → Service → Repository → Database

## 3. Directory Structure
src/
├── modules/ (or features/ or app/)
│   ├── auth/
│   │   ├── auth.controller.ts
│   │   ├── auth.service.ts
│   │   ├── auth.repository.ts
│   │   ├── auth.module.ts
│   │   ├── dto/
│   │   └── entities/
│   ├── users/
│   └── [other modules]/
├── common/ (shared utilities, guards, filters, interceptors)
├── config/ (environment config)
└── database/ (migrations, seeds)

## 4. Third-Party Integrations
| Service | Purpose | Auth Method | Rate Limits |
|---------|---------|-------------|-------------|

## 5. Security Architecture
- Authentication: [JWT / Session / OAuth2]
- Password hashing: bcrypt (min 12 rounds)
- API security: Helmet, CORS, rate limiting
- Input: class-validator / zod on EVERY endpoint
- SQL injection: parameterized queries ONLY (never string concat)
- XSS: sanitize all user input before storage AND display
- CSRF: token-based for cookie auth
- Secrets: .env only, never committed

## 6. Performance Strategy
- Database: indexes on FK + search columns, pagination mandatory
- API: response compression, field selection where applicable
- Frontend: lazy loading routes, image optimization, code splitting
- Caching: [Redis/in-memory] for [specific use cases]

## 7. Environment Configuration
| Variable | Description | Required | Default |
|----------|-------------|----------|---------|
| DATABASE_URL | ... | Yes | - |
| JWT_SECRET | ... | Yes | - |
```

---

### Doc 2: Database Schema (`docs/SCHEMA.md`) — all tiers

```markdown
# Database Schema

## Table: users
| Column | Type | Constraints | Default | Description |
|--------|------|-------------|---------|-------------|
| id | UUID | PK | gen_random_uuid() | ... |
| email | VARCHAR(255) | UNIQUE, NOT NULL | - | ... |
| password_hash | VARCHAR(255) | NOT NULL | - | ... |
| role | ENUM('admin','user') | NOT NULL | 'user' | ... |
| is_active | BOOLEAN | NOT NULL | true | ... |
| created_at | TIMESTAMPTZ | NOT NULL | NOW() | ... |
| updated_at | TIMESTAMPTZ | NOT NULL | NOW() | ... |
| deleted_at | TIMESTAMPTZ | NULLABLE | NULL | Soft delete |

## Indexes
| Table | Columns | Type | Reason |
|-------|---------|------|--------|
| users | email | UNIQUE | Login lookup |

## Relationships
| From | To | Type | FK Column | On Delete |
|------|----|------|-----------|-----------|
| orders | users | Many-to-One | user_id | CASCADE |

## Seed Data Requirements
- 1 admin user (admin@app.com / password123)
- 5 test users
- [feature-specific seed data]
```

---

### Doc 3: API Specification (`docs/API.md`) — Standard/Full tier

```markdown
# API Specification
Base URL: /api/v1
Auth: Bearer JWT (unless marked PUBLIC)

## Standard Response Format
Success: { "success": true, "data": T, "meta": { "page": 1, "total": 100 } }
Error: { "success": false, "error": "message", "details": [...] }

## Pagination
Query: ?page=1&limit=20&sort=created_at&order=desc
Response meta: { "page": 1, "limit": 20, "total": 100, "totalPages": 5 }

## Endpoints

### AUTH
| Method | Path | Auth | Description |
|--------|------|------|-------------|
| POST | /auth/register | PUBLIC | Register new user |
| POST | /auth/login | PUBLIC | Login, returns JWT |
| POST | /auth/refresh | JWT | Refresh token |
| POST | /auth/logout | JWT | Invalidate token |
| POST | /auth/forgot-password | PUBLIC | Send reset email |
| POST | /auth/reset-password | PUBLIC | Reset with token |

#### POST /auth/register
Request:
  { "email": "string (required, valid email)",
    "password": "string (required, min 8, 1 upper, 1 number)",
    "name": "string (required, 2-100 chars)" }
Success (201):
  { "success": true, "data": { "user": UserObject, "token": "jwt..." } }
Errors:
  422 - Validation failed (field-specific errors)
  409 - Email already exists

[Continue for ALL endpoints...]
```

---

### Doc 4: Business Rules (`docs/RULES.md`) — Standard/Full tier

```markdown
# Business Rules

## Authentication Rules
| ID | Rule | Logic | Error Message |
|----|------|-------|---------------|
| BR-001 | Password minimum strength | min 8 chars, 1 uppercase, 1 number | "Password must be at least 8 characters with 1 uppercase and 1 number" |
| BR-002 | Login lockout | 5 failed attempts → lock 15 minutes | "Account locked. Try again in {minutes} minutes" |

## Authorization Rules
| ID | Rule | Roles Allowed | Roles Denied |
|----|------|---------------|-------------|
| BR-010 | Create product | admin | user, guest |
| BR-011 | View own orders | admin, user | guest |

## Data Rules
| ID | Rule | Validation | Edge Case |
|----|------|------------|-----------|
| BR-020 | Order minimum amount | amount >= 1.00 | 0.99 should fail |
| BR-021 | Max items per order | items.length <= 50 | 51st item rejected |

## Workflow Rules
| ID | Rule | Trigger | Action |
|----|------|---------|--------|
| BR-030 | Order confirmation email | Order status → "confirmed" | Send email via [service] |
```

---

### Doc 5: Feature Registry (`docs/FEATURES.md`) — Full tier only

```markdown
# Feature Registry
Last updated: [date]

## Phase 1: Foundation
| ID | Feature | Priority | Status | Files | API ✅ | DB ✅ | Tested ✅ | Working ✅ |
|----|---------|----------|--------|-------|--------|-------|-----------|-----------|
| F-001 | User Registration | P0 | ⏳ | - | ❌ | ❌ | ❌ | ❌ |
| F-002 | User Login | P0 | ⏳ | - | ❌ | ❌ | ❌ | ❌ |

## Phase 2: Core Features
| ... |

## Summary
- Total Features: X
- Completed: 0 (0%)
- In Progress: 0
- Pending: X
```

---

### Doc 6: Task Breakdown (`docs/TASKS.md`) — Full tier only

```markdown
# Task Breakdown
Total tasks: X | Completed: 0 | Remaining: X

## Phase 1: Foundation [0/X complete]

### Setup Tasks
- [ ] T-001: Create database migrations for users table (depends: none) [Est: 1h]
  - AC: Migration runs successfully, table created with all columns from SCHEMA.md
  - AC: Rollback works correctly
  - Files: src/database/migrations/001_create_users.ts

- [ ] T-002: Create User entity/model (depends: T-001) [Est: 1h]
  - AC: Entity matches SCHEMA.md exactly
  - AC: TypeORM/Prisma/Drizzle decorators correct
  - Files: src/modules/users/entities/user.entity.ts

### Auth Tasks
- [ ] T-003: Implement registration endpoint (depends: T-002) [Est: 2h]
  - AC: POST /api/v1/auth/register works per API.md spec
  - AC: Validates all fields per BR-001
  - AC: Returns JWT token
  - AC: Password is hashed (bcrypt, 12 rounds)
  - AC: 409 if email exists
  - Files: auth.controller.ts, auth.service.ts, register.dto.ts
  - Tests: Register with valid data, duplicate email, weak password, missing fields

[Continue for ALL tasks...]

## Phase 1 Integration Checkpoint:
- [ ] Fresh signup → login → access protected route → logout works end-to-end
- [ ] Invalid credentials rejected
- [ ] Expired token rejected
- [ ] All auth endpoints return correct status codes
```

---

### Doc 7: Testing Strategy (`docs/TESTING.md`) — Full tier only

```markdown
# Testing Strategy

## Test Stack
- Unit: [Jest/Vitest] for services and utilities
- Integration: [Supertest] for API endpoints
- E2E: [Playwright CLI] --headed --persistent (4x more token efficient than MCP)
- Browser Debug: [Chrome DevTools MCP] for console, network, performance
- DB: Direct queries to verify data persistence

## Test Naming Convention
test('[Feature ID] [Scenario] → [Expected Result]')
Example: test('F-001 Register with valid data → returns 201 with token')

## Per-Feature Test Scenarios

### F-001: User Registration
| ID | Type | Scenario | Input | Expected | DB Check |
|----|------|----------|-------|----------|----------|
| TS-001-1 | Happy | Valid registration | valid email+pass | 201 + token | User row exists |
| TS-001-2 | Validation | Missing email | no email field | 422 + "email required" | No row |
| TS-001-3 | Validation | Weak password | "123" | 422 + password rules | No row |
| TS-001-4 | Conflict | Duplicate email | existing email | 409 | No duplicate |
| TS-001-5 | Edge | Max length email | 255 char email | 201 or 422 | Verify |
| TS-001-6 | Security | SQL injection in email | "'; DROP TABLE--" | 422 | Tables intact |
| TS-001-7 | Security | XSS in name | "<script>alert(1)</script>" | Sanitized | Clean data |

[Continue for ALL features...]

## E2E Flow Tests (run after each Phase)
### Phase 1 E2E:
| Flow | Steps | Assertions |
|------|-------|------------|
| Full Auth Flow | 1. Go to /register 2. Fill form 3. Submit 4. Redirected to dashboard 5. Logout 6. Login | User created in DB, JWT valid, dashboard shows user name, logout clears token |
```

---

### Doc 8: Session Tracker (`docs/SESSION.md`) — all tiers (tier-aware sections)

**Lite / Standard tiers — INCLUDES Feature Tracker section** (the dedicated FEATURES.md is not generated):

```markdown
# Session Tracker

## Current State
- Tier: [Lite / Standard]
- Phase: 0 (Initialization)
- Last completed: Project scaffold
- Current task: Document generation
- Blockers: None
- Context health: Fresh

## Feature Tracker (Lite/Standard tier — replaces FEATURES.md)
| ID | Feature | Priority | Status | Files | Tested ✅ | Working ✅ | Notes |
|----|---------|----------|--------|-------|-----------|-----------|-------|
| F-001 | [feature name from PRD] | P0 | ⏳ pending | - | ❌ | ❌ | - |
| F-002 | [feature name] | P0 | ⏳ pending | - | ❌ | ❌ | - |

Status legend: ⏳ pending | 🚧 in progress | ✅ done | ⚠️ blocked

## Session History
| # | Date | Tasks Done | Phase Progress | Notes |
|---|------|-----------|----------------|-------|
| 1 | [today] | Setup | Phase 0: 10% | Initial scaffold |

## Next Actions
1. Complete document generation
2. Run /compact
3. Start Phase 1, F-001
```

**Full tier — OMITS Feature Tracker (uses dedicated FEATURES.md instead)**:

```markdown
# Session Tracker

## Current State
- Tier: Full
- Phase: 0 (Initialization)
- Last completed: Project scaffold
- Current task: Document generation
- Blockers: None
- Context health: Fresh

## Session History
| # | Date | Tasks Done | Phase Progress | Notes |
|---|------|-----------|----------------|-------|

## Next Actions
1. Complete document generation
2. Run /compact
3. Start Phase 1, T-001
```

**On every feature completion (Lite/Standard tier):** update the Feature Tracker row's Status, Files, Tested, Working columns. This row is the single source of truth for feature progress in non-Full projects.

---

## Step 0.4 — Verification & Commit

```
After tier docs are generated:
1. Count: features in FEATURES.md vs PRD → must match (Full tier)
2. Count: every feature has tasks in TASKS.md → must match (Full tier)
3. Count: every feature has test scenarios in TESTING.md → must match (Full tier)
4. Verify: DESIGN.md has colors, typography, spacing, component tokens (all tiers)
5. Print summary (tier-aware):
   "✅ Phase 0 Complete (Tier: [Lite/Standard/Full])"
   "📄 Documents: [list of generated docs]"
6. git add -A && git commit -m "docs: complete project documentation (Phase 0 — [tier])"
7. Run /compact to free context
8. Say: "Ready for Phase 1. Say 'Go' to begin development."
```

---

*Back to CLAUDE.md core for routing rules.*
