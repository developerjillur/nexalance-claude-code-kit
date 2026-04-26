# NexaLance Claude Code Kit — v4.4 LITE+

> **The complete AI development operating system for Claude Code.**
> Token-optimized, quality-preserved, production-hardened.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Compatible-orange.svg)](https://claude.ai/code)
[![Version](https://img.shields.io/badge/version-v4.4_LITE%2B-success)](https://github.com/developerjillur/nexalance-claude-code-kit/releases)
[![Token Reduction](https://img.shields.io/badge/tokens-70%25_reduction-brightgreen)](#token-savings)
[![Plugins](https://img.shields.io/badge/Plugins-8_Integrated-green.svg)](#integrated-plugins)

---

## 🎯 What This Is

A production-ready CLAUDE.md system that solves the biggest pains of running Claude Code on real, large projects:

| Pain | How this kit fixes it |
|------|------------------------|
| Claude burns context fast on big projects | **v4.4 LITE: ~70% token reduction**, lazy-loaded playbooks, tiered Phase 0 |
| Memory lost between sessions | **MemPalace** integration with wing isolation per project |
| Code review doesn't scale | **Risk-tiered review** — 5-agent for security, inline for routine |
| Quality drops on multi-task plans | **Deep Focus Mode** + inline self-review checklist |
| MemPalace "sometimes" doesn't work | **`diagnose-mempalace.sh`** + interpreter auto-detection (fixes pyenv/python3 issues) |
| Mock/stub data sneaks into production | **Zero Mock Data Rule** + connection-chain verification |
| Browser tests waste tokens | **Playwright CLI** (4× cheaper than MCP) + DOM-targeted snapshots |
| Multi-project context bleed | **MemPalace Wings** — fully isolated memory per project |
| Tokens balloon on large codebases | **Optional Graphify** — knowledge-graph queries, ~71× cheaper than re-reading files |
| No enforcement of token rules | **Runtime hooks** — playbook-tracker, cache-warn, reset-counter |

---

## ⭐ What's New in v4.4 LITE+

### Token-optimized

- **Slim CLAUDE.md core** (~6K tokens, was ~24K in v4.3) + **11 lazy-loaded playbooks** read only when relevant
- **Tier-aware Phase 0**: `lite` (3 docs) / `standard` (6, default) / `full` (9), instead of always-9
- **Risk-tiered review**: inline 5-question check by default, escalates to 5-agent `/code-review` only for security-sensitive / pre-PR
- **Inline self-review** — saves an LLM round-trip per task; full 7-category fallback still available when escalated
- **Haiku subagent dispatch** rules for cheap auxiliary tasks (doc updates, status reports, routine commits)
- **Cache discipline** + Playwright `--interactive-only` snapshot optimization

**Verified token math:** typical session **80–120K → 25–40K** (~65–70% reduction). Quality bar preserved — every v4.3 rule is either in the slim core or in a lazy-loaded playbook.

### Production-hardened

- **`hooks/` runtime enforcement** (3 scripts auto-installed by setup):
  - `playbook-tracker.sh` — counts playbook reads/turn, warns if > 2
  - `cache-warn.sh` — warns when CLAUDE.md is edited mid-session (would break prompt cache)
  - `reset-counter.sh` — resets per-turn counter on each user prompt
- **Tier-aware Feature Tracker** in SESSION.md for Lite/Standard tiers (closes a real gap from v4.3)
- **MemPalace reliability fixes** — auto-detects working Python 3, uses absolute paths, eliminates silent hook failures (root cause of the "MemPalace sometimes doesn't work" reports)

### New tools

- **`diagnose-mempalace.sh`** — 12-check health diagnostic; pinpoints the exact failing layer with the exact fix command
- **`migrate-to-v44.sh`** — idempotent v4.3 → v4.4 LITE migration; auto-detects existing wing config, full backup, 6-check verification, safe rollback
- **`setup-graphify.sh`** — optional Graphify codebase knowledge graph integration (~71× cheaper structural queries on large codebases)

---

## 📦 What's in the Kit

```
nexalance-claude-code-kit/
├── NexaLance-CLAUDE-v4.4-LITE.md       ⭐ Slim core (~6K tokens) — RECOMMENDED
├── NexaLance-CLAUDE-v4.3-FINAL.md       Legacy monolith (~24K tokens)
│
├── playbooks/                           11 lazy-loaded modules
│   ├── phase-0.md                       Phase 0 doc generation (tier-aware)
│   ├── feature-workflow.md              Feature implementation + phase-based dev
│   ├── testing.md                       Action-Level Testing protocol
│   ├── browser-automation.md            Playwright CLI + Chrome DevTools
│   ├── self-review-full.md              7-category fallback (escalation only)
│   ├── session-management.md            Session start/middle/end + Exit Gate
│   ├── persistent-memory.md             MemPalace setup + wing protocol
│   ├── plugin-orchestration.md          Plugin priority + conflict matrix
│   ├── patterns.md                      Common + anti-patterns
│   ├── operations.md                    File routing + deployment + rollback
│   └── mempalace-troubleshooting.md     Symptom → cause → fix reference
│
├── hooks/                               3 runtime enforcement scripts
│   ├── playbook-tracker.sh              Counts playbook reads/turn
│   ├── cache-warn.sh                    Warns on mid-session CLAUDE.md edits
│   └── reset-counter.sh                 Resets per-turn counter
│
├── setup-nexalance.sh                   One-time machine setup (interpreter auto-detection)
├── setup-project-wing.sh                Per-project setup (tier-aware, wires hooks)
├── setup-graphify.sh                    Optional Graphify integration
├── migrate-to-v44.sh                    Safe v4.3 → v4.4 LITE migration
├── diagnose-mempalace.sh                12-check MemPalace health diagnostic
├── README.md                            This file
├── LICENSE                              MIT
└── .gitignore
```

---

## 🚀 Quick Start (5 minutes)

### 1. Clone this repo

```bash
git clone https://github.com/developerjillur/nexalance-claude-code-kit.git ~/Desktop/nexalance-kit
cd ~/Desktop/nexalance-kit
chmod +x *.sh hooks/*.sh
```

### 2. Run machine setup (once per machine)

```bash
bash setup-nexalance.sh
```

Installs MemPalace + plugins (Superpowers, Code Review, Feature Dev, Frontend Design) + Playwright CLI + Chromium + Chrome DevTools MCP + design tooling. **Auto-detects** your working Python 3 interpreter so MCP and hooks use the right one — no more pyenv/python3 surprises.

### 3. Set up your first project (v4.4 LITE recommended)

```bash
mkdir -p ~/projects/my-project && cd ~/projects/my-project

# Copy the LITE core + playbooks
cp ~/Desktop/nexalance-kit/NexaLance-CLAUDE-v4.4-LITE.md ./CLAUDE.md
cp -r ~/Desktop/nexalance-kit/playbooks ./playbooks

# Init project (tier: lite | standard | full — default standard)
bash ~/Desktop/nexalance-kit/setup-project-wing.sh \
    "my-project" "My Awesome Project" "client-name" standard

# Drop your PRD in docs/PRD.md, then open in VS Code
code .
```

### 4. Start building

In Claude Code panel, type:

```
Start project
```

Claude reads `CLAUDE.md` → reads `playbooks/phase-0.md` (lazy-loaded) → generates the docs your tier requires → asks for `Go`. Type **Go**. Building begins.

---

## 📊 Token Savings

| Stage | v4.3 | **v4.4 LITE+** | Saving |
|-------|------|------------|--------|
| CLAUDE.md baseline load | ~24K | **~6K** | **−75%** |
| One playbook on demand | n/a | ~1–3K | (was always-loaded) |
| Phase 0 (Standard tier, 6 docs) | ~18–30K | **~12–18K** | −33% |
| Routine feature + inline review | ~25–40K | **~8–15K** | **−65%** |
| Security feature + 5-agent review | ~30–40K | ~25–35K | preserved (full depth on purpose) |
| **Typical session total** | **~80–120K** | **~25–40K** | **−65 to −70%** |

Quality bar identical: every rule from v4.3 is either in the slim core (non-negotiables) or a lazy-loaded playbook (deep detail). Nothing removed.

---

## 🪜 Tier System

Set `PROJECT_TIER` once at project init; Phase 0 generates only what's needed.

| Tier | Phase 0 docs | Feature progress lives in | Use for |
|------|--------------|---------------------------|---------|
| `lite` | DESIGN, SCHEMA, SESSION (3) | `SESSION.md` → Feature Tracker | MVPs, prototypes, small tools |
| `standard` *(default)* | + TAD, API, RULES (6) | `SESSION.md` → Feature Tracker | Most production work |
| `full` | + FEATURES, TASKS, TESTING (9) | Dedicated `FEATURES.md` | Enterprise, multi-team, regulated |

Tier flag is just the 4th argument to `setup-project-wing.sh`:

```bash
bash setup-project-wing.sh "my-wing" "Project" "client" lite     # 3 docs
bash setup-project-wing.sh "my-wing" "Project" "client" standard # 6 docs (default)
bash setup-project-wing.sh "my-wing" "Project" "client" full     # 9 docs
```

Need a doc your tier didn't generate? Generate it on demand later — no need to re-init.

---

## 🪝 Runtime Hooks (v4.4 LITE+)

Auto-installed by `setup-project-wing.sh` into `.claude/hooks/`. Wired into `.claude/settings.json` for the project. They observe and warn — they never block.

| Hook | Fires on | What it does |
|------|----------|--------------|
| `playbook-tracker.sh` | `Read` of `playbooks/*.md` | Counts reads/turn, prints warning if > 2 |
| `cache-warn.sh` | `Edit/Write` of `CLAUDE.md` or playbooks | Warns about prompt-cache invalidation |
| `reset-counter.sh` | `UserPromptSubmit` | Resets per-turn playbook counter |

Counter state lives at `.claude/.playbook-counter` (gitignored). Run `cat .claude/.playbook-counter` mid-session to see how many playbooks Claude read in the current turn — single best signal that token budget is healthy.

---

## 🩺 MemPalace Not Working? Run the Diagnostic First

The single most common issue: `python` (the bare command) doesn't resolve to Python 3 on your machine — common on macOS pyenv users, modern macOS without legacy aliases, and python3-only Linux. Older versions of the kit hardcoded `python -m mempalace.mcp_server`, which silently failed.

**Diagnose any MemPalace problem in 5 seconds:**

```bash
cd ~/projects/your-project
bash ~/Desktop/nexalance-kit/diagnose-mempalace.sh
```

The script runs **12 checks** across all layers (interpreter, package install, MCP registration, project `.mcp.json`, hooks, `PROJECT_WING` value, wing data, MCP server liveness, and more) and prints **prioritized root causes** with the exact fix command for each.

**Surgical one-liner if you already know it's the python issue:**

```bash
PY=$(command -v python3)
claude mcp remove mempalace --scope user 2>/dev/null
claude plugin uninstall mempalace 2>/dev/null
claude mcp add mempalace --scope user -- "$PY" -m mempalace.mcp_server
sed -i.bak "s|python -m mempalace|$PY -m mempalace|g" ~/.claude/settings.json
# Restart Claude Code, then verify:
claude mcp list | grep mempalace
```

For full symptom→cause→fix reference, see [`playbooks/mempalace-troubleshooting.md`](playbooks/mempalace-troubleshooting.md).

**v4.4 LITE+ structural fixes (auto-applied if you re-run setup-nexalance.sh):**
- Auto-detects working Python 3 interpreter, uses absolute path everywhere
- Removes duplicate project-level MCP entry
- Hook errors log to `~/.mempalace-hook.log` instead of `/dev/null`
- Wing init errors are visible
- Refuses placeholder wing names (`"project-wing-name"`)
- Wing seeded with 4 triples on init so `mempalace_search` returns data immediately

---

## 🔄 Migrating an Existing Project from v4.3 → v4.4 LITE

**One command (recommended):**

```bash
cd ~/projects/your-existing-project
bash ~/Desktop/nexalance-kit/migrate-to-v44.sh standard   # or: lite | full
```

Auto-detects existing `PROJECT_WING`, `PROJECT_NAME`, `CLIENT`. Backs up to `.nexalance-backup-<timestamp>/`. Installs LITE core + 11 playbooks + 3 hooks. Upgrades `SESSION.md` to add Feature Tracker for Lite/Standard tiers (preserves history). Runs **6 verification checks** before declaring success. **Idempotent** — re-running on an already-migrated project aborts safely.

**Rollback (paths in script output):**

```bash
cp .nexalance-backup-<timestamp>/CLAUDE.md.v43 CLAUDE.md
cp .nexalance-backup-<timestamp>/settings.json.v43 .claude/settings.json
rm -rf playbooks/ .claude/hooks/
```

---

## 🕸️ Optional Add-On: Graphify (Codebase Knowledge Graph)

For **large or multi-language codebases**, add Graphify — a knowledge-graph index over your code, docs, papers, and images. Claude queries the graph instead of re-reading files (~71× fewer tokens per structural query).

**Layer model:**

| Layer | Tool | What it stores |
|-------|------|----------------|
| Episodic ("what we did") | **MemPalace** | conversation memory, decisions, per-project wings |
| Semantic ("what the code IS") | **Graphify** | structure, deps, call graph, doc concepts |
| Session state | **SESSION.md / HANDOFF.md** | current task, next step |

### Install (once per machine)

```bash
bash ~/Desktop/nexalance-kit/setup-graphify.sh
```

### Use it (per project)

```bash
# In Claude Code, after Phase 0:
/graphify .

# Common queries:
/graphify query "how does the auth flow work?"
/graphify path "LoginForm" "sessionStore"
/graphify .  --update                       # incremental refresh
/graphify clone https://github.com/foo/bar  # index an external repo
/graphify merge-graphs g1.json g2.json      # cross-repo graph
```

**When to add it:** ✅ Codebase >30k LOC, multi-language, lots of `/docs` PDFs/specs. ❌ Skip for tiny projects, greenfield/empty repos, or pure PRD work.

CLAUDE.md core has a rule: query `graph.json` BEFORE Glob/Grep on >20 files when `graphify-out/` exists. Auto-applied.

---

## 🔄 Daily Workflow

### Start working

```
1. Open VS Code with your project folder
2. Open Claude Code panel (Spark icon)
3. Type: "Continue" or "Resume"
4. Claude loads MemPalace memory → reads SESSION.md → resumes the exact task
```

### Switch projects

```
1. Open a different project folder
2. Open Claude Code panel
3. Type: "Continue"
4. MemPalace switches to that project's wing automatically — zero context bleed
```

### End your day

```
1. Type: "I'm done for today"
2. Claude automatically:
   → Runs Session Exit Gate (codebase review + tests)
   → Runs risk-tiered review (5-agent if pre-PR; otherwise inline)
   → Saves to MemPalace
   → Updates SESSION.md + HANDOFF.md
   → Git commits all progress
```

### Natural commands (no plugin syntax to remember)

```
"Build the user auth system"   → /feature-dev auto-runs
"Test the login form"           → Playwright CLI opens browser
"Why is this page broken?"      → Chrome DevTools checks console
"Review the code"               → tier-appropriate review (inline or 5-agent)
"Plan the payment integration"  → Superpowers brainstorm
"Deploy to hosting"             → Playwright CLI headed browser
```

---

## 🔌 Integrated Plugins

| Plugin | Purpose | Auto-trigger |
|--------|---------|--------------|
| **Superpowers** | Brainstorm → Plan → TDD → Execute | New ideas / planning |
| **MemPalace** | Persistent memory across sessions | Every session start/end |
| **Code Review** | 5-agent parallel review | Security-sensitive or pre-PR |
| **Feature Dev** | 7-phase feature implementation | Complex features |
| **Frontend Design** | Anti-AI-slop design quality | Any frontend work |
| **Playwright CLI** | Browser testing (4× cheaper than MCP) | Testing, deploying |
| **Chrome DevTools** | Console, network, performance debugging | UI bugs |
| **Vercel Guidelines** | 100+ UX/accessibility rules | UI quality checks |
| **Graphify** *(opt-in)* | Codebase knowledge graph | Big-codebase exploration |

---

## 🏗️ Multi-Project Setup

Each project gets its own MemPalace "wing" — fully isolated memory:

```bash
# Project 1 (Standard tier)
cd ~/projects/project-alpha
cp ~/Desktop/nexalance-kit/NexaLance-CLAUDE-v4.4-LITE.md ./CLAUDE.md
cp -r ~/Desktop/nexalance-kit/playbooks ./playbooks
bash ~/Desktop/nexalance-kit/setup-project-wing.sh "alpha" "Project Alpha" "client-a" standard

# Project 2 (Full tier — enterprise)
cd ~/projects/project-beta
cp ~/Desktop/nexalance-kit/NexaLance-CLAUDE-v4.4-LITE.md ./CLAUDE.md
cp -r ~/Desktop/nexalance-kit/playbooks ./playbooks
bash ~/Desktop/nexalance-kit/setup-project-wing.sh "beta" "Project Beta" "client-b" full

# Switching: just open the folder → Claude loads correct wing
```

---

## ❓ Troubleshooting

<details>
<summary><strong>MemPalace shows "Failed to connect"</strong></summary>

```bash
bash ~/Desktop/nexalance-kit/diagnose-mempalace.sh
```

The script identifies the exact root cause and prints the fix command. Most common: the kit's older configs hardcoded `python` which fails on pyenv / python3-only systems. Re-running `setup-nexalance.sh` from the v4.4 LITE+ release auto-fixes this.

</details>

<details>
<summary><strong>Playwright CLI "not found"</strong></summary>

```bash
npm install -g @playwright/cli
npx playwright install chromium
```

</details>

<details>
<summary><strong>Plugin not installed</strong></summary>

In Claude Code:
```
/plugin marketplace add obra/superpowers-marketplace
/plugin install superpowers@superpowers-marketplace
/plugin install code-review@claude-plugins-official
/plugin install feature-dev@claude-plugins-official
/plugin install frontend-design@claude-plugins-official
```

</details>

<details>
<summary><strong>Context getting heavy / slow responses</strong></summary>

In Claude Code: `/compact`. Or start a new session — MemPalace preserves all context. Also check `.claude/.playbook-counter` — if > 2, you've been reading too many playbooks per turn (review the routing table in CLAUDE.md core).

</details>

<details>
<summary><strong>Browser test needs login</strong></summary>

Tell Claude: "Open browser and navigate to [URL]". Browser opens (headed mode); you log in manually; tell Claude: "Continue testing".

</details>

<details>
<summary><strong>New session lost context</strong></summary>

Type: "Read docs/HANDOFF.md and docs/SESSION.md, then resume." With MemPalace properly working, this happens automatically. If it doesn't → run the diagnostic.

</details>

<details>
<summary><strong>Wing memory bleeding between projects</strong></summary>

Every MemPalace operation MUST include `--wing PROJECT_WING`. Check that `PROJECT_WING` in each project's CLAUDE.md is unique. Audit recent calls: search for `mempalace_search` in your transcript and verify each has `--wing`.

</details>

<details>
<summary><strong>Hook errors flooding `~/.mempalace-hook.log`</strong></summary>

This file is good news — it means hooks are firing and you can see what's failing. Common entries:

- `ModuleNotFoundError: No module named 'mempalace'` → re-run `setup-nexalance.sh` (interpreter mismatch)
- `pyenv: python: command not found` → same fix
- `Permission denied` → `chmod -R u+w ~/.mempalace`

</details>

---

## 📈 Version History

| Version | Lines | Score | Key change |
|---------|-------|-------|------------|
| v2.0 | 415 | 7.2 | Basic orchestrator |
| v3.0 | 913 | 9.1 | Security, deployment, rollback |
| v4.0 | 1,409 | 9.6 | Deep focus, action testing, self-review, memory |
| v4.1 | 1,641 | 9.6 | Superpowers + MemPalace + Official plugins |
| v4.2 | 1,793 | 8.4 | Playwright CLI + Chrome DevTools |
| v4.3 | 2,350+ | 9.2 | Design system, conflict resolution, file organization |
| **v4.4 LITE+** | core ~530 + playbooks ~2,000 | **9.0** | **Token-optimized: slim core + lazy-loaded playbooks, tiered Phase 0, risk-tiered review, inline self-review, Haiku dispatch + post-review hardening: tier-aware feature tracking, routing enforcement hook, cache-break warning hook, idempotent migration script, MemPalace reliability fixes, 12-check diagnostic, Graphify integration** |

---

## 🏢 Credits

Built by **NexaLance Agency** — a full-service digital agency delivering 500+ projects across 30+ countries since 2016.

- Website: [nexalance.com](https://nexalance.com)
- GitHub: [@developerjillur](https://github.com/developerjillur)
- Email: info@sorobindu.com

Engineering co-pilot: Claude Opus 4.7 (1M context).

---

## 📄 License

MIT License — free to use, modify, and distribute.

---

*NexaLance Agency — Your Success, Our Mission.*
