# Playbook: Common Patterns + Anti-Patterns

> **When Claude reads this:** implementing pagination, search, file upload, soft delete, audit, websocket, email, cron, background jobs — OR before writing code that might match an anti-pattern.

## 🛠️ COMMON PATTERNS (reference when implementing)

### Pagination (use for ALL list endpoints)

```typescript
// Query: GET /api/v1/items?page=1&limit=20&sort=created_at&order=desc
// Service returns: { data: Item[], meta: { page, limit, total, totalPages } }
// Frontend: shows page controls + "Showing 1-20 of 100"
```

### Search & Filter

```typescript
// Query: GET /api/v1/items?search=keyword&status=active&category=electronics
// Backend: WHERE (name ILIKE '%keyword%' OR description ILIKE '%keyword%') AND status = 'active'
// Frontend: search input + filter dropdowns + clear filters button
```

### File Upload

```typescript
// Multer/formidable on backend
// Validate: file type (whitelist), size (max 10MB), filename (sanitize)
// Store: local disk or S3/CloudStorage (configurable via env)
// DB: store file path/URL, original name, size, mime type
// Frontend: drag-drop zone + progress bar + preview
```

### Soft Delete

```typescript
// Never actually DELETE from database
// Add deleted_at TIMESTAMPTZ column
// "Delete" = SET deleted_at = NOW()
// All queries: WHERE deleted_at IS NULL (unless admin viewing trash)
// Restore: SET deleted_at = NULL
```

### Audit Trail (if required by PRD)

```typescript
// audit_logs table: id, entity_type, entity_id, action, old_value, new_value, user_id, created_at
// Service: log EVERY create, update, delete action
```

### WebSocket / Real-time (if required)

```typescript
// Use Socket.io or native WebSocket
// Events: connect, disconnect, message, error
// Auth: verify JWT on connection (not per message)
// Rooms: per-user or per-resource rooms for targeted updates
// Frontend: reconnection logic with exponential backoff
// Fallback: polling every 5s if WebSocket fails
```

### Email Sending

```typescript
// Use Nodemailer + SMTP or SendGrid/Resend/SES
// Templates: HTML email templates (not inline strings)
// Queue: Send async via job queue (not blocking API response)
// Retry: 3 retries with exponential backoff on failure
// Logging: Log send attempts, successes, failures
// Dev mode: use Ethereal/Mailtrap (never send real emails in dev)
```

### Cron Jobs / Scheduled Tasks

```typescript
// Use node-cron or BullMQ scheduled jobs
// Log: every run start + end + result
// Error handling: catch and log, don't crash the server
// Idempotent: safe to run twice (no duplicate side effects)
// Config: schedule in .env (not hardcoded)
// Examples: cleanup expired tokens, send reminder emails, sync data
```

### Background Job Queue

```typescript
// Use BullMQ + Redis (or @nestjs/bull)
// Pattern: API receives request → adds job to queue → returns 202 Accepted
// Worker: processes jobs async, retries on failure
// Use for: email, image processing, PDF generation, webhooks, data sync
// Dashboard: Bull Board or Arena for monitoring
```

---

## 🚫 ANTI-PATTERNS (NEVER DO THESE)

```
CODE QUALITY:
  ❌ Hardcoded data in production components
  ❌ console.log as error handling
  ❌ @ts-ignore / as any
  ❌ Ignoring linter errors
  ❌ Hardcoding URLs, ports, or API keys
  ❌ String concatenation in SQL queries
  ❌ Storing passwords in plain text

WORKFLOW:
  ❌ Working on multiple tasks simultaneously
  ❌ Skipping tests "for now"
  ❌ Moving to next Phase with failing tests
  ❌ Re-reading all docs when you only need one
  ❌ Starting over instead of fixing
  ❌ Reading playbooks you don't need (waste of context)

ARCHITECTURE:
  ❌ Frontend calling database directly
  ❌ Business logic in controllers (belongs in services)
  ❌ Validation only on frontend (must be on backend too)
  ❌ Creating API endpoints that return dummy data
  ❌ Creating forms that don't submit to real APIs

DESIGN (avoid "AI slop"):
  ❌ Purple/blue gradient backgrounds (most obvious AI tell)
  ❌ Random hex colors not from DESIGN.md palette
  ❌ Random font sizes not from typography scale
  ❌ Random padding/margin values not from 8px grid
  ❌ Building buttons/inputs from scratch (use shadcn/ui)
  ❌ Missing hover/focus states on interactive elements
  ❌ No loading skeletons (just empty space while loading)
  ❌ Generic "No data" text (use illustrated empty states)
  ❌ Same border-radius everywhere (vary: sm chips, md buttons, lg cards)
  ❌ White (#fff) backgrounds everywhere (use subtle #fafbfc or #f8fafc)
  ❌ Centering ALL text (left-align body, center only headings)
  ❌ Ignoring dark mode when DESIGN.md specifies it

TOKEN-WASTE (NEW in v4.4):
  ❌ Loading multiple playbooks "just in case"
  ❌ Editing CLAUDE.md core mid-session (breaks prompt cache)
  ❌ Running 5-agent review on routine features
  ❌ Running self-review as a separate LLM pass when inline checks pass
  ❌ Re-snapshotting same page on every action (use --interactive-only)
  ❌ Using main model for trivial doc updates (dispatch to Haiku)
```

---

*Back to CLAUDE.md core.*
