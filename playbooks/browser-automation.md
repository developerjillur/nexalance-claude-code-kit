# Playbook: Browser Automation (Playwright CLI + Chrome DevTools)

> **When Claude reads this:** triggered when the task involves a browser — testing, deploying, debugging UI, screenshots.

## Why Playwright CLI instead of Playwright MCP

```
Playwright MCP:  ~114,000 tokens per task → context burns fast
Playwright CLI:  ~27,000 tokens per task → 4x more efficient
Same Playwright engine, same power, just smarter token usage.
Snapshots save to disk files, not into context window.
Screenshots save to disk, not injected as token-heavy images.
```

## Playwright CLI Usage (--headed = see browser, --persistent = keep session)

```bash
# ─── SETUP: Create screenshot folders on first use ───
mkdir -p .screenshots/{tests,reviews,deployments,bugs}

# ─── NAVIGATION ───
# Open browser (visible + session persists):
playwright-cli navigate https://site.com --headed --persistent

# Get page snapshot (compact YAML, ~2K tokens vs ~13K in MCP):
playwright-cli snapshot
# Returns element refs: e8, e15, e21, e35...

# Get only interactive elements (forms, buttons — minimal output):
playwright-cli snapshot --interactive-only

# Wait for page to settle after navigation:
playwright-cli wait-for-load

# ─── INTERACTION ───
playwright-cli click e15              # Click button
playwright-cli fill e8 "hello@mail.com"  # Fill input
playwright-cli fill e12 "Password123"    # Fill password
playwright-cli click e21              # Submit
playwright-cli press Enter            # Press key
playwright-cli check e35              # Check checkbox
playwright-cli select e40 "option1"   # Select dropdown

# ─── SCREENSHOTS (always save to .screenshots/ — NEVER project root) ───

# Test screenshots:
playwright-cli screenshot --output .screenshots/tests/$(date +%Y-%m-%d)_F001-login-success.png

# Design review screenshots:
playwright-cli screenshot --output .screenshots/reviews/$(date +%Y-%m-%d)_homepage-desktop.png

# Deployment proof:
playwright-cli screenshot --output .screenshots/deployments/$(date +%Y-%m-%d)_deploy-complete.png

# Bug evidence:
playwright-cli screenshot --output .screenshots/bugs/$(date +%Y-%m-%d)_broken-layout.png

# If --output not available, move after capture:
playwright-cli screenshot
mv .playwright-cli/*.png .screenshots/tests/$(date +%Y-%m-%d)_description.png
```

## Snapshot Discipline (token-saving — NEW in v4.4)

- One **full** snapshot per page on arrival.
- Subsequent actions: `--interactive-only` for that page.
- Refresh the full snapshot only if URL changes or DOM clearly mutated.
- Use `[data-testid="..."]` queries when you know the target — skips parsing the full tree.

## Screenshot Naming Convention

```
Format: YYYY-MM-DD_description.png

Examples:
  .screenshots/tests/2026-04-14_F001-login-valid-submit.png
  .screenshots/tests/2026-04-14_F001-login-empty-form-error.png
  .screenshots/reviews/2026-04-14_dashboard-mobile-375px.png
  .screenshots/reviews/2026-04-14_dashboard-desktop-1440px.png
  .screenshots/deployments/2026-04-14_vercel-deploy-success.png
  .screenshots/bugs/2026-04-14_sidebar-overflow-mobile.png

RULE: NEVER leave screenshots in project root.
      ALWAYS move/save to .screenshots/[category]/
```

## Chrome DevTools MCP Usage (debugging)

Use when you need to see INSIDE the browser:
- "Check browser console for errors"
- "Which API call is failing?"
- "What's the page performance score?"
- "Show me network requests to /api/*"

Chrome DevTools gives you:
- ✅ Console logs + errors (with source-mapped stack traces)
- ✅ Network requests + responses (headers, body, status)
- ✅ Performance profiling (LCP, CLS, TBT, Core Web Vitals)
- ✅ DOM tree inspection
- ✅ JavaScript runtime errors

## Browser Auto-Routing

```
╔═══════════════════════════════════════════════════════════════╗
║  TASK                              → TOOL                    ║
╠═══════════════════════════════════════════════════════════════╣
║  "Test the login form"             → Playwright CLI          ║
║  "Deploy via hosting panel"        → Playwright CLI (headed) ║
║  "Check for console errors"        → Chrome DevTools MCP     ║
║  "Which API is failing?"           → Chrome DevTools MCP     ║
║  "Screenshot all pages"            → Playwright CLI          ║
║  "Fill form and submit"            → Playwright CLI          ║
║  "Test user signup flow"           → Playwright CLI          ║
║  "Page performance check"          → Chrome DevTools MCP     ║
║  "WordPress admin update"          → Playwright CLI (headed) ║
║  "E2E test full user journey"      → Playwright CLI          ║
║  "Debug: page shows spinner"       → Chrome DevTools MCP     ║
╚═══════════════════════════════════════════════════════════════╝
```

## Login-Required Workflows (--persistent keeps session)

```
Scenario: Client's WordPress admin panel

1. Claude Code runs: playwright-cli navigate https://client.com/wp-admin --headed --persistent
2. Browser opens → user sees it
3. User logs in (password + 2FA if needed)
4. Claude Code takes over:
   → playwright-cli snapshot → sees admin dashboard
   → playwright-cli click e45 → "Plugins" menu
   → playwright-cli click e52 → "Update All"
   → playwright-cli screenshot --output .screenshots/deployments/$(date +%Y-%m-%d)_wp-plugin-update.png
5. Session stays alive → next command uses same logged-in session
6. Total tokens: ~15K (not 114K!)
```

---

*Back to CLAUDE.md core. For test patterns, see `playbooks/testing.md`.*
