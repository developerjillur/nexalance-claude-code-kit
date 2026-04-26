# Playbook: Action-Level Testing Protocol

> **When Claude reads this:** triggered when writing/running tests, or when the workflow says "Action-Level Testing."

## CRITICAL: Test Like a REAL USER, Not a Robot

```
⛔ WHAT CLAUDE CODE USUALLY DOES (WRONG):
  - Opens the page → "It loads" → PASS ❌
  - Checks if a button is visible → "Button exists" → PASS ❌
  - Runs the server → "No errors in console" → PASS ❌
  - Checks component renders → "Component mounted" → PASS ❌

✅ WHAT YOU MUST DO (ACTION-LEVEL TESTING):
  - Opens the page → clicks EVERY button → verifies EACH action's result
  - Fills EVERY form field → submits → checks DB has the data
  - Tests EVERY error path → wrong input → checks error message shows
  - Navigates EVERY route → checks content loads with REAL data
  - Tests EVERY user role → admin sees X, user sees Y, guest is blocked
```

## Action-Level Test Protocol

For EVERY feature, test EVERY interactive element:

```
BUTTONS:
  □ Click every button on the page
  □ Verify each button's action completes (not just that button exists)
  □ Check: does the button trigger an API call?
  □ Check: does the API call return correct data?
  □ Check: does the UI update after the action?
  □ Check: does the database state change?
  □ Test button in disabled state (when should it be disabled?)
  □ Test rapid double-click (should it be debounced?)

FORMS:
  □ Fill with valid data → submit → verify success message + DB entry
  □ Submit empty → verify all required field errors show
  □ Fill each field with invalid data ONE AT A TIME → verify specific error
  □ Fill with boundary values (max length, min value, special chars)
  □ Test paste, autofill behavior
  □ Test form reset/clear functionality

LISTS/TABLES:
  □ Verify data comes from API (not hardcoded)
  □ Test with 0 items → empty state shows
  □ Test with 1 item → displays correctly
  □ Test with many items → pagination works
  □ Test search/filter → results update correctly
  □ Test sort → order changes correctly
  □ Click on item → navigates to detail view with correct data

NAVIGATION:
  □ Every link goes to correct page
  □ Browser back/forward works
  □ Direct URL access works (not just clicking through)
  □ Protected routes redirect to login
  □ After login, redirects back to intended page

CRUD OPERATIONS (for EACH entity):
  □ CREATE: Fill form → submit → item appears in list → exists in DB
  □ READ: List shows correct data → detail page shows all fields
  □ UPDATE: Change fields → save → list reflects changes → DB updated
  □ DELETE: Click delete → confirm → item removed from list → removed from DB
  □ NOT FOUND: Access non-existent ID → proper 404 page/message
```

## Test Execution Per Task

```
1. Write test FIRST or DURING implementation
2. Run test → must PASS before marking task done
3. Tests must assert SPECIFIC values:
   ❌ expect(response.status).toBeTruthy()     // meaningless
   ✅ expect(response.status).toBe(201)         // specific
   ❌ expect(user).toBeDefined()                // too vague
   ✅ expect(user.email).toBe('test@mail.com')  // specific
4. Report format: "Tests: 5 passed, 0 failed, 0 skipped"
```

## Playwright/E2E Action Testing (using Playwright CLI)

```
EVERY E2E test uses Playwright CLI for token efficiency.
--headed = browser visible | --persistent = session stays

=== FULL FLOW TEST EXAMPLE ===

# Step 1: ARRANGE — Start browser + seed data
playwright-cli navigate http://localhost:3000/register --headed --persistent

# Step 2: SNAPSHOT — See what's on page
playwright-cli snapshot
# Output: e5=name input, e8=email input, e12=password input, e21=submit button

# Step 3: ACT — Fill form like real user
playwright-cli fill e5 "Test User"
playwright-cli fill e8 "test@example.com"
playwright-cli fill e12 "SecurePass123"
playwright-cli click e21

# Step 4: WAIT — Page loads after submit
playwright-cli wait-for-load

# Step 5: ASSERT UI — Snapshot new page, check content
playwright-cli snapshot
# → Look for "Welcome, Test User" in snapshot output
# → Verify URL changed to /dashboard

# Step 6: SCREENSHOT — Visual proof (organized folder, zero token cost)
playwright-cli screenshot --output .screenshots/tests/$(date +%Y-%m-%d)_F001-register-success.png

# Step 7: ASSERT DB — Verify database directly
# Run SQL: SELECT * FROM users WHERE email = 'test@example.com'
# Verify: user exists, password_hash != plain text

# Step 8: TEST ERROR PATHS — Same session, go back
playwright-cli navigate http://localhost:3000/register
playwright-cli fill e8 "test@example.com"  # duplicate email
playwright-cli fill e12 "SecurePass123"
playwright-cli click e21
playwright-cli snapshot
# → Look for "Email already exists" error message

# Step 9: TEST VALIDATION — Empty form
playwright-cli navigate http://localhost:3000/register
playwright-cli click e21  # submit empty
playwright-cli snapshot
# → Look for "Email is required", "Password is required"

=== TOKEN COMPARISON ===
This full test with Playwright CLI:  ~20K tokens
Same test with Playwright MCP:       ~114K tokens
Savings:                             ~94K tokens per test!
```

## Snapshot Optimization Rule (NEW in v4.4)

To preserve quality while reducing token spend:
- Snapshot the **page once** when arriving on it.
- For each subsequent action on the same page, use `playwright-cli snapshot --interactive-only` (forms/buttons only) — saves ~60% per re-snapshot.
- Use `[data-testid="..."]` selectors for known elements — skip the full ARIA tree.
- Re-snapshot the full page only when the URL changes or you suspect significant DOM mutation.

This keeps coverage identical while typically saving 3-10K tokens per UI test.

## Why Playwright CLI over Playwright MCP for testing

```
Playwright CLI advantages:
  ✅ snapshot → compact YAML file on disk (~2K tokens vs ~13K inline)
  ✅ screenshot → file on disk (zero token cost vs ~50K inline)
  ✅ Element refs (e8, e21) → compact vs full accessibility tree
  ✅ --persistent → login once, test many pages
  ✅ --headed → see what's happening in real time
  ✅ Same Playwright engine → same reliability
  ✅ 4x fewer tokens → more tests per session

When to add Chrome DevTools MCP:
  🔧 playwright-cli shows button click did nothing →
     Chrome DevTools: "Console error: TypeError at line 42"
  🔧 Page shows spinner forever →
     Chrome DevTools: "GET /api/data 504 Gateway Timeout"
  🔧 Page looks broken →
     Chrome DevTools: "CSS file 404 Not Found"
```

NEVER write a test that only does:

```
playwright-cli navigate http://localhost:3000/dashboard
playwright-cli snapshot
# → "Page loaded" ← THIS TESTS NOTHING

ALWAYS check specific content in snapshot output!
```

## Test Coverage Minimum

- Every API endpoint: at least happy path + 1 validation + 1 auth test
- Every form: submit success + validation errors + empty submission
- Every CRUD: create + read list + read single + update + delete + not found
- Every button: clicked and action verified
- Every list: with 0 items, 1 item, and many items

---

*Back to CLAUDE.md core. For browser automation tooling, see `playbooks/browser-automation.md`.*
