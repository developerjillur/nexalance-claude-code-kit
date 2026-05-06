# Playbook: LLM Wiki — Per-Project Knowledge Base

> **When Claude reads this:** every session start where `docs/wiki/.synthesis-pending` exists, OR when the user asks a domain/recall question, OR when the user drops a file in `docs/wiki/raw/inbox/`.
>
> **Pattern source:** [Karpathy's LLM Wiki gist](https://gist.github.com/karpathy/442a6bf555914893e9891c11519de94f). Adapted for nexalance-kit so it runs **fully automatically** with zero manual user action after setup.

---

## What this layer is

The LLM Wiki is a per-project, persistent, LLM-maintained knowledge base. It's a **different layer** from MemPalace, Graphify, and SESSION.md:

| Layer | Stores | Lifetime | Maintained by |
|-------|--------|----------|----------------|
| MemPalace | Episodic memory (conversations, decisions) | Session-to-session | Hooks, automatic |
| Graphify *(opt-in)* | Code semantic index | Rebuilt on demand | `/graphify` command |
| SESSION.md | Current task state | Live | Hooks, manual |
| **LLM Wiki** | **Domain knowledge — the project's "world"** | **Persistent, compounding** | **You (Claude), automatic ingest + on-demand synthesis** |

**Concrete examples for the wiki:**
- Synthesized competitor pages (for SaaS/e-commerce)
- Customer interview themes
- Decision log with rationale (auth approach, schema choice, library picks)
- Glossary of project-domain terms
- Prompt patterns that work / don't work for this project
- Reference papers, articles, screenshots the user dropped in
- Past conversation summaries (auto-ingested from Claude Code session JSONL)

---

## The folder layout (auto-created by `setup-project-wing.sh`)

```
docs/wiki/
├── CLAUDE.md                       ← Wiki-internal schema (this file is referenced from there)
├── index.md                        ← Catalog of every wiki page (LLM-maintained)
├── log.md                          ← Append-only audit (LLM + hook write to this)
├── raw/                            ← Immutable sources
│   ├── discussions/                ← Auto-ingested Claude Code session transcripts (gitignored by default)
│   ├── prompts/                    ← Raw prompts the user has tested (frontmatter: worked/failed/notes)
│   ├── articles/                   ← Articles, papers, PDFs, screenshots the user dropped in
│   ├── interviews/                 ← Customer interviews, calls, transcripts
│   └── inbox/                      ← Unsorted drops; you triage on demand
├── synthesized/                    ← LLM-generated wiki pages (committed to git)
│   ├── domain-glossary.md
│   ├── decision-log.md
│   ├── prompt-patterns.md
│   └── _entities/                  ← Per-entity pages (concepts, people, products, modules)
├── .ingest-manifest.json           ← Hook state (do not edit)
├── .synthesis-pending              ← Flag file (presence = pending work; you delete after synthesis)
└── .ingest.log                     ← Hook diagnostics (last-run, errors)
```

---

## How it runs automatically (no user action needed)

### Half 1 — Plumbing (hook-driven, no LLM)

`hooks/wiki-ingest.py` is wired into `.claude/settings.json` to run on **`SessionStart`** and **`SessionEnd`**. It:

1. Finds `~/.claude/projects/<encoded-cwd>/` for the current project
2. For each `*.jsonl` not yet processed (per `docs/wiki/.ingest-manifest.json`):
   - Parses user/assistant `text` content (skips internal `thinking`/`tool_use`/`tool_result`)
   - Applies basic secret redaction (sk-…, ghp_…, AKIA…, Bearer …, PASSWORD=…)
   - Skips sessions modified within the last 60s (the in-flight current session)
   - Writes markdown to `docs/wiki/raw/discussions/<date>-<short-id>.md`
3. Updates manifest + appends to `log.md`
4. Touches `.synthesis-pending` so you know there's work to do

This step costs **zero LLM tokens**, runs in ~50–250ms, and is idempotent.

### Half 2 — Thinking (you do this, when convenient)

When `.synthesis-pending` exists, you (Claude) do the LLM-driven half. **Where to do it without surprising the user:**

- **Best:** When the user explicitly asks a domain/recall question that the wiki could answer. Synthesize what's needed for the answer.
- **Good:** Right after the Session Exit Gate finishes (user is wrapping up; one more LLM turn for synthesis is acceptable).
- **OK:** First user message of a session, IF you can do a quick synthesis without delaying their actual request more than ~1 turn.
- **❌ Don't:** Auto-synthesize on every SessionStart silently — wastes tokens and surprises the user.

When you do synthesize, follow the workflow below.

---

## Workflow A: Ingest a new raw source

**Trigger:** A new file appeared in `docs/wiki/raw/{discussions,articles,interviews,inbox}/` (check by reading `.synthesis-pending` flag).

```
1. Read the new raw file(s).
2. For each file:
   a. Identify entities, concepts, decisions worth filing.
   b. Decide which existing pages in synthesized/_entities/ to UPDATE
      and which NEW pages to create.
   c. Update touched pages with cross-references back to raw source
      (e.g., "[2026-04-14 session](../raw/discussions/2026-04-14-a912714a.md)").
   d. If the source is in inbox/, MOVE it to the appropriate raw/ subfolder.
3. Update docs/wiki/index.md:
   a. Add new page entries with one-line summary.
   b. Re-sort/categorize as needed.
4. Append to docs/wiki/log.md:
   ## [YYYY-MM-DD HH:MM] synthesize | <source-file> | touched: pageA, pageB, pageC
5. Delete docs/wiki/.synthesis-pending (or remove just the entries you handled).
```

**Token efficiency:** typically 1 source touches 3–10 wiki pages. Don't load the whole wiki — read `index.md` first, drill only into the pages your synthesis touches.

---

## Workflow B: Query the wiki (user asks a domain question)

**Trigger:** User asks something like "What did we decide about auth?", "What competitors did we research?", "What prompts have worked for X feature?", "Recall what was discussed last week."

```
1. Read docs/wiki/index.md FIRST. It's small and tells you what pages exist.
2. Identify 2–4 pages relevant to the question.
3. Read just those pages.
4. Synthesize an answer with citations:
   "Per [decision-log.md](docs/wiki/synthesized/decision-log.md#auth-approach),
    we chose JWT in session [2026-04-14](docs/wiki/raw/discussions/2026-04-14-a912714a.md)
    because…"
5. If the answer is high-quality and reusable, file it as a new page in
   synthesized/_entities/ or synthesized/queries/, then append to log.md.
```

**Critical:** never re-read raw discussions unless `index.md` doesn't have what you need. The whole point of the wiki is that you're querying compiled knowledge, not re-deriving it.

---

## Workflow C: Lint (run periodically — every 5–10 ingests)

**Trigger:** When `.synthesis-pending` shows ≥5 unprocessed entries, or when the user explicitly asks for a wiki health check.

```
1. Read docs/wiki/index.md.
2. Check for:
   - Orphan pages (in synthesized/ but not in index.md)
   - Stale claims (page says X, but a newer raw source contradicts it)
   - Missing cross-references (page A mentions concept B but doesn't link to its page)
   - Duplicate entities (multiple pages for the same concept under different names)
   - Empty/stub pages (page < 50 words)
3. Fix what you can fix safely. Flag the rest in synthesized/_lint-report.md.
4. Append to log.md:
   ## [YYYY-MM-DD HH:MM] lint | fixed: N | flagged: M
```

---

## File conventions

### Frontmatter (recommended for synthesized/ pages)

```markdown
---
title: Auth Decision Log
type: decision
tags: [auth, security, jwt]
last_updated: 2026-05-06
sources:
  - ../raw/discussions/2026-04-14-a912714a.md
  - ../raw/articles/jwt-vs-sessions-2026.md
---
```

### Naming

- `synthesized/_entities/<lowercase-hyphenated>.md` — one file per entity/concept
- `synthesized/<topic>.md` — single-page topics (decision-log, glossary, prompt-patterns)
- `raw/discussions/YYYY-MM-DD-<short-id>.md` — auto-named by hook (don't rename)
- `raw/prompts/YYYY-MM-DD-<slug>.md` — user drops these
- `raw/articles/YYYY-MM-DD-<slug>.md` — user drops these (or web-clipper)

### Linking

- Use relative markdown links: `[Page](../synthesized/decision-log.md)`
- Always cite raw sources: every claim in synthesized/ should link to a raw file
- Use `[[Wikilinks]]` only if the project also uses Obsidian — both syntaxes work in Obsidian; only relative links work elsewhere

---

## Privacy + Git policy (defaults set in `.gitignore`)

| Path | Committed? | Why |
|------|-----------|------|
| `docs/wiki/CLAUDE.md` | ✅ yes | Schema, no secrets |
| `docs/wiki/index.md` | ✅ yes | Catalog, no secrets |
| `docs/wiki/log.md` | ✅ yes | Audit trail |
| `docs/wiki/synthesized/**` | ✅ yes | LLM-cleaned synthesis |
| `docs/wiki/raw/discussions/**` | ❌ no (gitignored) | Auto-ingested raw transcripts may contain secrets |
| `docs/wiki/raw/articles/**` | ✅ yes | User-curated, vetted |
| `docs/wiki/raw/prompts/**` | ✅ yes | User-curated |
| `docs/wiki/raw/interviews/**` | ❌ no (gitignored) | May contain PII |
| `docs/wiki/.ingest-manifest.json` | ❌ no | Local state |
| `docs/wiki/.synthesis-pending` | ❌ no | Local flag |
| `docs/wiki/.ingest.log` | ❌ no | Local diagnostics |

User can opt-in to committing raw discussions later by editing `.gitignore` if their project has no privacy concerns (e.g., personal projects).

---

## When the wiki helps vs when it doesn't

**✅ Use the wiki when:**
- User asks "what did we decide about X" / "what was that approach we tried"
- Answering domain questions where prior research is relevant
- Building on previous sessions' work without re-reading them all
- Cross-cutting concerns (security, performance, design system) that need consistent treatment
- Multi-week / multi-month projects where sessions accumulate

**❌ Don't bother with the wiki for:**
- Pure code questions (`how do I write X in TypeScript`) — that's general knowledge
- Questions about CURRENT task state — use SESSION.md
- Questions about codebase structure — use Graphify (if installed) or grep
- One-off small projects (< 1 week of sessions) — overhead exceeds value

---

## Diagnostic signals

| Symptom | Likely cause | Fix |
|---------|--------------|-----|
| `.synthesis-pending` keeps growing, never gets processed | You (Claude) aren't doing Workflow A — synthesize next time the user asks anything wiki-relevant | Process the queue at next user turn |
| Same entity has multiple pages with slightly different names | Lint hasn't run in a while | Run Workflow C |
| Wiki answers are stale (cite old decisions that were superseded) | Wiki not being updated — stuck in query-only mode | After answering, file the answer back into wiki and update outdated pages |
| Hook never runs (no files in `raw/discussions/`) | Hook misconfigured or `~/.claude/projects/` empty | Check `docs/wiki/.ingest.log`; verify `.claude/settings.json` has `SessionStart` hook entry |
| Tokens balloon when wiki is queried | Reading too many pages — read `index.md` first, drill only into 2–4 | Re-read this playbook's "Workflow B" |

---

*Back to CLAUDE.md core. Related: `playbooks/persistent-memory.md` (MemPalace — episodic complement), `playbooks/session-management.md` (SESSION.md — current state), Graphify in CLAUDE.md (codebase semantic index).*
