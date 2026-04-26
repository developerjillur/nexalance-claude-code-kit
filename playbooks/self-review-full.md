# Playbook: Full Self-Review & Rating (Fallback)

> **When Claude reads this:** the LITE core has an **inline 5-question checklist** that runs as part of implementation (no extra LLM pass). Read THIS playbook only when:
> - The inline checklist surfaces a Risk = HIGH item, OR
> - User explicitly requests a full self-review, OR
> - You're about to merge a milestone PR (in addition to the 5-agent review).

This is the v4.3 7-category rating used as a thoroughness fallback. It costs an extra LLM round-trip — only run it when the situation justifies it.

---

## Rule: NEVER move to next task without reviewing the current one.

### Primary Method: Use /code-review Plugin (if available)

```
After implementing ANY feature or task that crossed the inline-review escalation bar:

1. Run /code-review on the changed files
   → 5 parallel review agents analyze your code:
     - CLAUDE.md compliance
     - Bug detection
     - Historical context
     - PR history patterns
     - Code quality comments
   → Fix ALL issues found

2. Then do your own self-rating (Step 1 below)
   → /code-review catches technical issues
   → Self-rating catches completeness and connection issues

If /code-review plugin is NOT available → do full manual review below.
```

### Fallback: Manual Self-Review

After completing the task, run this self-review loop:

### Step 1: Rate Your Own Work (1-10 scale)

| Category | Score | Criteria |
|----------|-------|----------|
| Code Quality | ?/10 | Clean, readable, DRY, proper naming, no shortcuts |
| Completeness | ?/10 | All acceptance criteria met, no stubbed functions |
| Error Handling | ?/10 | All error paths handled, meaningful messages |
| Security | ?/10 | Input validated, auth checked, no vulnerabilities |
| Testing | ?/10 | Tests cover happy + error + edge cases |
| Connection Chain | ?/10 | DB ↔ API ↔ UI all connected with real data |
| Design Quality | ?/10 | Follows DESIGN.md, shadcn components, no AI slop (frontend tasks only) |
| **OVERALL** | ?/10 | Average (skip Design Quality for backend-only tasks) |

### Step 2: Find Gaps (be brutally honest)

Ask yourself:
1. "What did I skip or leave incomplete?"
2. "What edge case did I NOT handle?"
3. "Where did I take a shortcut?"
4. "What would break if a user did something unexpected?"
5. "Is there any hardcoded/mock data?"
6. "Are there any console.log() that should be proper error handling?"
7. "Does every form field validate properly?"
8. "Does every API endpoint return proper status codes?"
9. "Would this code pass a code review by a strict senior developer?"

### Step 3: Improve (if OVERALL < 8.5)

```
If your self-rating is below 8.5/10:
  1. List the specific gaps found in Step 2
  2. Fix EACH gap immediately
  3. Re-rate after fixes
  4. Repeat until OVERALL >= 8.5

If your self-rating is 8.5+/10:
  1. Document what makes it good
  2. Proceed to next task
```

### Step 4: Report

```
🔍 SELF-REVIEW: T-XXX
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
Code Quality:     [X/10]
Completeness:     [X/10]
Error Handling:   [X/10]
Security:         [X/10]
Testing:          [X/10]
Connection Chain: [X/10]
Design Quality:   [X/10 or N/A]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
OVERALL:          [X/10]
Gaps Found:       [list or "None"]
Improvements Made:[list or "N/A"]
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Apply Self-Review to ALL Outputs (when escalated)

This isn't just for code. Apply to:
- Generated documents (PRD analysis, TAD, API spec) → review for completeness
- Plans and task breakdowns → review for gaps in coverage
- Architectural decisions → review for missed considerations
- Test scenarios → review for missed edge cases

---

## When to escalate from inline → full review

| Trigger | Action |
|---------|--------|
| Inline review found unresolved Risk=HIGH item | Run full 7-category here |
| Touched auth, payments, PII, file uploads, or RBAC | Full review **and** /code-review |
| Pre-PR / pre-merge to main | Full review **and** /code-review |
| User asks for "a deep review" | Full review |
| Routine feature with all inline checks PASS | **Do NOT escalate.** Inline is enough. |

---

*Back to CLAUDE.md core. The inline 5-question version is the default — this playbook is the deep fallback.*
