# NexaLance Claude Code Kit v4.3 SUPREME

> **The Complete AI Development Operating System for Claude Code**
> Transform Claude Code from a coding assistant into a full engineering team.

[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](LICENSE)
[![Claude Code](https://img.shields.io/badge/Claude_Code-Compatible-orange.svg)](https://code.claude.com)
[![Plugins](https://img.shields.io/badge/Plugins-8_Integrated-green.svg)](#integrated-plugins)

---

## 🤔 What is This?

A **production-ready CLAUDE.md system** that solves the biggest problems developers face with Claude Code on large projects:

| Problem | How This Kit Solves It |
|---------|----------------------|
| Claude Code skips details on multiple tasks | **Deep Focus Mode** — single-task enforcement |
| Features are static/don't work | **Zero Mock Data Rule** — real API + DB connections enforced |
| Testing is superficial | **Action-Level Testing** — every button clicked, every form submitted |
| No self-review after implementation | **Mandatory Self-Review** — 7-category rating, 8.5/10 threshold |
| Context lost when starting new chat | **MemPalace Integration** — persistent memory across sessions |
| Claude Code doesn't give 100% effort | **Max Effort Protocol** — lazy output detection + quality gates |
| Session ends without validation | **Session Exit Gate** — codebase review before summary |
| Design quality poor vs Lovable.dev | **Design System** — DESIGN.md + shadcn/ui + ShadcnBlocks |
| Browser testing burns too many tokens | **Playwright CLI** — 4x more efficient than Playwright MCP |
| Multi-project context bleed | **MemPalace Wings** — per-project isolated memory |

---

## 📦 What's in the Kit

```
nexalance-claude-code-kit/
├── NexaLance-CLAUDE-v4.4-LITE.md       ← ⭐ Slim core (~6K tokens) + lazy-loaded playbooks
├── NexaLance-CLAUDE-v4.3-FINAL.md       ← Legacy monolithic template (~24K tokens)
├── diagnose-mempalace.sh                ← ⭐ NEW: 12-check MemPalace health diagnostic
├── playbooks/                           ← 11 lazy-loaded modules (read on demand)
│   ├── phase-0.md                       ← Phase 0 doc generation (tier-aware)
│   ├── feature-workflow.md              ← Feature implementation + phase-based dev
│   ├── testing.md                       ← Action-Level Testing protocol
│   ├── browser-automation.md            ← Playwright CLI + Chrome DevTools
│   ├── self-review-full.md              ← 7-category fallback (escalation only)
│   ├── session-management.md            ← Session start/middle/end + Exit Gate
│   ├── persistent-memory.md             ← MemPalace setup + wing protocol
│   ├── plugin-orchestration.md          ← Plugin priority + conflict matrix
│   ├── patterns.md                      ← Common + anti-patterns
│   ├── operations.md                    ← File routing + deployment + rollback + conflicts
│   └── mempalace-troubleshooting.md     ← ⭐ NEW: MemPalace symptom→cause→fix reference
├── hooks/                               ← ⭐ NEW: v4.4 LITE enforcement hooks
│   ├── playbook-tracker.sh              ← Counts playbook reads/turn, warns if > 2
│   ├── cache-warn.sh                    ← Warns when CLAUDE.md edited mid-session
│   └── reset-counter.sh                 ← Resets counter on each new turn
├── setup-nexalance.sh                   ← One-time machine setup
├── setup-project-wing.sh                ← Per-project setup (tier-aware, wires hooks)
├── setup-graphify.sh                    ← Optional: codebase knowledge graph
├── migrate-to-v44.sh                    ← ⭐ NEW: Safe v4.3 → v4.4 LITE migration
├── README.md                            ← This file
└── LICENSE                              ← MIT License
```

---

## ⭐ v4.4 LITE — 70% Fewer Tokens, Zero Quality Compromise

**v4.4 LITE** is the recommended template for new projects. It splits the v4.3 monolith into:

- A slim **core CLAUDE.md** (~7K tokens — was ~24K) loaded every session
- **10 lazy-loaded playbooks** under `playbooks/` — Claude reads only the one matching the current task

| Metric | v4.3 FINAL | **v4.4 LITE** | Saving |
|---|---|---|---|
| CLAUDE.md baseline load | ~24K tokens | **~7K tokens** | -71% |
| Routine feature session | 80-120K | **25-40K** | ~65-70% |
| Quality bar | 8.5/10 self-review | **Same — preserved** | 0 |

**5 optimizations baked in (every rule from v4.3 preserved):**

1. **Slim core + lazy-loaded playbooks** — read at most ONE playbook per task (enforced by hook ⭐)
2. **Tiered Phase 0** — `lite` (3 docs) / `standard` (6) / `full` (9) instead of always-9
3. **Risk-tiered review** — inline 5-question check for routine, escalates to 5-agent only for security-sensitive / pre-PR
4. **Inline self-review (no extra LLM pass)** — saves ~2-4K per task; 7-category fallback still available when escalated
5. **Haiku subagent dispatch** for cheap auxiliary tasks (doc updates, status reports, routine commits)

Plus:
- **Prompt-cache discipline** with a hook that warns on mid-session CLAUDE.md edits ⭐
- **Playwright snapshot optimization** — `--interactive-only` after first full snapshot
- **Tier-aware feature tracking** — `SESSION.md` → Feature Tracker for Lite/Standard, dedicated `FEATURES.md` for Full ⭐
- **Routing enforcement hook** — counts playbook reads per turn, warns if > 2 ⭐

⭐ = post-review hardening (review identified gaps; these close them)

---

## 🚀 Quick Start (5 minutes)

### Step 1: Clone this repo
```bash
git clone https://github.com/developerjillur/nexalance-claude-code-kit.git ~/Desktop/nexalance-kit
cd ~/Desktop/nexalance-kit
chmod +x setup-nexalance.sh setup-project-wing.sh setup-graphify.sh
```

### Step 2: Run machine setup (one time only)
```bash
bash setup-nexalance.sh
```
This installs: Superpowers, MemPalace, Code Review, Feature Dev, Frontend Design, Playwright CLI, Chrome DevTools MCP, Vercel Design Guidelines, and auto-save hooks.

### Step 3: Set up your first project (recommended — v4.4 LITE)
```bash
mkdir -p ~/projects/my-project && cd ~/projects/my-project

# Copy the LITE core + playbooks
cp ~/Desktop/nexalance-kit/NexaLance-CLAUDE-v4.4-LITE.md ./CLAUDE.md
cp -r ~/Desktop/nexalance-kit/playbooks ./playbooks

# Initialize project with isolated memory wing + tier
# Tier: lite | standard (default) | full
bash ~/Desktop/nexalance-kit/setup-project-wing.sh "my-project" "My Awesome Project" "client-name" standard

# Add your PRD in docs/PRD.md
# Open in VS Code
code .
```

**Or use legacy v4.3 monolithic template (no playbooks needed):**
```bash
cp ~/Desktop/nexalance-kit/NexaLance-CLAUDE-v4.3-FINAL.md ./CLAUDE.md
bash ~/Desktop/nexalance-kit/setup-project-wing.sh "my-project" "My Awesome Project" "client-name"
```

### Step 4: Start building
Open Claude Code panel in VS Code → type:
```
Start project
```

> **Claude Code may ask:** "What would you like to start?" or "Is this a new project?"
> 
> **Reply with this:**
> ```
> This is a new project. Read the CLAUDE.md in the project root and follow the Phase 0 initialization protocol. The PRD is in docs/PRD.md which references the PRD files in docs/ folder. Read all of them and generate all 9 documents as instructed in CLAUDE.md.
> ```

After that, Claude Code will automatically:
1. Read your CLAUDE.md (2,350+ lines of instructions)
2. Read your PRD file(s)
3. Generate 9 documents (DESIGN, TAD, SCHEMA, API, RULES, FEATURES, TASKS, TESTING, SESSION)
4. Print summary
5. Ask: "Ready for Phase 1. Say 'Go' to start building."
6. Type **"Go"** → development starts!

---

## 🕸️ Optional Add-On: Graphify (Codebase Knowledge Graph)

For **large or multi-language codebases**, add Graphify — a knowledge-graph index over your code, docs, papers, and images. Claude Code queries the graph instead of re-reading files, claiming ~71× fewer tokens per structural query.

**Layer model:**

| Layer | Tool | Purpose |
|-------|------|---------|
| Episodic ("what we did") | **MemPalace** | conversation memory, decisions, per-project wings |
| Semantic ("what the code IS") | **Graphify** | classes, deps, call graph, doc concepts |
| Session state | **SESSION.md / HANDOFF.md** | current task, next step |

### Install (one time, after `setup-nexalance.sh`)
```bash
bash ~/Desktop/nexalance-kit/setup-graphify.sh
```
Installs the `graphifyy` PyPI package and registers `/graphify` as a slash command in Claude Code.

### Use it (per project)
```bash
# Inside Claude Code, after Phase 0 docs are generated:
/graphify .

# Result: ./graphify-out/ with graph.json, graph.html, GRAPH_REPORT.md, cache/
```

### Common queries
```
/graphify query "how does the auth flow work?"
/graphify path "LoginForm" "sessionStore"
/graphify .  --update                       # incremental refresh
/graphify clone https://github.com/foo/bar  # index an external repo
/graphify merge-graphs g1.json g2.json      # cross-repo graph
```

### When to add it
- ✅ Codebase >30k LOC, multi-language, lots of `/docs` PDFs/specs
- ✅ Frequently asked architectural questions ("where is X called from?")
- ✅ New chat sessions need fast orientation on existing code
- ❌ Skip for tiny projects, greenfield/empty repos, or pure PRD work

The CLAUDE.md template includes a rule that tells Claude Code to **query `graph.json` BEFORE Glob/Grep on >20 files** when `graphify-out/` exists. No action needed beyond installing.

### .gitignore additions per project
```
graphify-out/cache/
# Optional: commit graph.json + GRAPH_REPORT.md so teammates and future
# Claude Code sessions get instant context without re-running.
```

---

## 📋 Detailed Setup Guide

### Prerequisites

| Tool | Required | Check Command |
|------|----------|--------------|
| Node.js 18+ | ✅ | `node --version` |
| Python 3.9+ | ✅ | `python3 --version` |
| Git | ✅ | `git --version` |
| Claude Code CLI | ✅ | `claude --version` |
| VS Code | Recommended | - |

### Machine Setup (One Time)

```bash
cd ~/Desktop/nexalance-kit
bash setup-nexalance.sh
```

**What this script does:**

```
✅ Checks prerequisites (Python, Node, Git, Claude CLI)
✅ Installs MemPalace (persistent AI memory)
✅ Installs Superpowers plugin (brainstorm + plan + TDD workflow)
✅ Installs Code Review plugin (5-agent parallel review)
✅ Installs Feature Dev plugin (7-phase implementation)
✅ Installs Frontend Design plugin (anti-AI-slop design)
✅ Installs Playwright CLI (4x token-efficient browser testing)
✅ Installs Chromium browser (for Playwright)
✅ Configures Chrome DevTools MCP (browser debugging)
✅ Configures MemPalace MCP (user-level, available in all projects)
✅ Configures auto-save hooks (every 15 messages + before /compact)
✅ Installs ShadcnBlocks skill (2,500+ UI blocks)
✅ Installs Vercel Web Design Guidelines (100+ UX rules)
```

### New Project Setup

```bash
cd ~/projects/your-project

# Copy master CLAUDE.md
cp ~/Desktop/nexalance-kit/NexaLance-CLAUDE-v4.3-SUPREME.md ./CLAUDE.md

# Run project setup (creates all config files + folders)
bash ~/Desktop/nexalance-kit/setup-project-wing.sh "wing-name" "Project Full Name" "client"
```

**Parameters:**
| Parameter | Description | Example |
|-----------|-------------|---------|
| `wing-name` | Short identifier (lowercase, no spaces) | `my-saas-app` |
| `Project Full Name` | Human-readable name | `My SaaS Application` |
| `client` | Client identifier (optional) | `client123` |

**What this script creates:**

```
your-project/
├── CLAUDE.md                       ← With PROJECT_WING configured
├── .mcp.json                       ← MemPalace + TaskMaster servers
├── .gitignore                      ← Proper ignore rules
├── .claude/
│   ├── settings.json               ← Auto-save hooks
│   └── commands/
│       └── auto-orchestrator.md    ← Plugin auto-routing skill
├── .screenshots/
│   ├── tests/                      ← E2E test screenshots
│   ├── reviews/                    ← Design review screenshots
│   ├── deployments/                ← Deploy proof screenshots
│   └── bugs/                       ← Bug evidence screenshots
├── docs/
│   ├── SESSION.md                  ← Session state tracker
│   ├── HANDOFF.md                  ← Session handoff for new chats
│   ├── reviews/                    ← Code review reports
│   ├── analysis/                   ← Technical analysis docs
│   └── plans/                      ← Implementation plans
└── .git/                           ← Git initialized
```

---

## 🔄 Daily Workflow

### Start working
```
1. Open VS Code with your project folder
2. Open Claude Code panel (Spark icon in sidebar)
3. Type: "Continue" or "Resume"
4. Claude Code loads MemPalace memory → reads SESSION.md → resumes exact task

Note: If Claude Code asks what to do, reply:
"Read the CLAUDE.md and docs/SESSION.md, then resume where you left off."
```

### Switch projects
```
1. Open different project folder in VS Code
2. Open Claude Code panel
3. Type: "Continue"
4. MemPalace automatically switches to that project's wing
5. Zero context bleed between projects
```

### End your day
```
1. Type: "I'm done for today"
2. Claude Code automatically:
   → Runs Session Exit Gate (codebase review + tests)
   → Runs /code-review
   → Saves memory to MemPalace
   → Updates SESSION.md + HANDOFF.md
   → Git commits all progress
```

### Natural commands (no plugin syntax needed)
```
"Build the user auth system"        → /feature-dev auto-runs
"Test the login form"               → Playwright CLI opens browser
"Check why this page is broken"     → Chrome DevTools checks console
"Review the code"                   → /code-review 5-agent analysis
"Plan the payment integration"      → Superpowers brainstorm
"Deploy to hosting"                 → Playwright CLI headed browser
```

---

## 🔌 Integrated Plugins

| Plugin | Purpose | Auto-triggers When |
|--------|---------|-------------------|
| **Superpowers** | Brainstorm → Plan → TDD → Execute | New ideas, planning |
| **MemPalace** | Persistent memory across sessions | Every session start/end |
| **Code Review** | 5-agent parallel code review | After every feature |
| **Feature Dev** | 7-phase feature implementation | Building complex features |
| **Frontend Design** | Anti-AI-slop design quality | Any frontend work |
| **Playwright CLI** | Browser testing (4x efficient) | Testing, deploying |
| **Chrome DevTools** | Console, network, performance | Debugging browser issues |
| **Vercel Guidelines** | 100+ UX/accessibility rules | UI quality checks |
| **Graphify** *(opt-in)* | Codebase knowledge graph (~71× cheaper structural queries) | Asking about existing code structure on big projects |

---

## 📊 CLAUDE.md Features (25 sections, 2,350+ lines)

### Core Systems
- **Auto-Orchestration** — All plugins trigger automatically based on context
- **Deep Focus Mode** — Single-task enforcement, no shallow multi-tasking
- **Maximum Effort Protocol** — Lazy output detection + quality enforcement
- **Plugin Priority Rules** — Clear conflict resolution between plugins

### Development
- **Phase 0: Document Generation** — 9 docs auto-generated from PRD (DESIGN, TAD, SCHEMA, API, RULES, FEATURES, TASKS, TESTING, SESSION)
- **Phase-Based Development** — 5 phases with integration checkpoints
- **Feature Workflow** — 8-step: context → backend → frontend → chain verify → review → git → memory → next
- **Design System** — DESIGN.md auto-generated with colors, typography, spacing, component tokens

### Quality
- **Action-Level Testing** — Every button, form, CRUD operation tested via Playwright CLI
- **Self-Review & Rating** — 7-category scoring (including Design Quality), 8.5/10 threshold
- **Session Exit Gate** — 5-step validation before ending any session
- **Security Checklist** — Applied to every feature

### Memory & Context
- **MemPalace Wings** — Per-project isolated memory, zero cross-project bleed
- **Context Management** — Progressive disclosure, rate limit handling
- **HANDOFF.md** — Session context preservation for new chats
- **Token Tracking** — Context health monitoring, /compact suggestions

### Code Standards
- **9 Common Patterns** — Pagination, search, upload, soft delete, audit, WebSocket, email, cron, job queue
- **Anti-Patterns** — Code + workflow + architecture + 12 design anti-patterns
- **Conflict Resolution** — PRD contradictions, business rule conflicts, tech decisions
- **Git Branch Workflow** — Feature branches with merge protocol
- **Organized File Output** — Screenshots in `.screenshots/`, reviews/analysis/plans in `docs/`

---

## 🏗️ Multi-Project Setup

Each project gets its own MemPalace "wing" — completely isolated memory:

```bash
# Project 1
cd ~/projects/project-alpha
cp ~/Desktop/nexalance-kit/NexaLance-CLAUDE-v4.3-SUPREME.md ./CLAUDE.md
bash ~/Desktop/nexalance-kit/setup-project-wing.sh "alpha" "Project Alpha" "client-a"

# Project 2
cd ~/projects/project-beta
cp ~/Desktop/nexalance-kit/NexaLance-CLAUDE-v4.3-SUPREME.md ./CLAUDE.md
bash ~/Desktop/nexalance-kit/setup-project-wing.sh "beta" "Project Beta" "client-b"

# Switching: just open the folder → Claude Code loads correct wing
```

---

## 🩺 MemPalace not working? Run the diagnostic first.

The single most common issue is that `python` (bare command) doesn't resolve to Python 3 on your machine — common on macOS pyenv users, modern macOS without legacy aliases, and python3-only Linux. Older kit versions hardcoded `python -m mempalace.mcp_server` in MCP and hook commands, which silently failed.

**Diagnose any MemPalace problem in 5 seconds:**
```bash
cd ~/projects/your-project
bash ~/Desktop/nexalance-kit/diagnose-mempalace.sh
```
The script runs **12 checks** across all layers (Python interpreter, mempalace install, MCP registration, project .mcp.json, hooks, PROJECT_WING value, wing data, MCP server liveness, etc.) and prints **prioritized root causes** with the exact fix command for each.

**v4.4 LITE+ fixes** (auto-applied if you re-run `setup-nexalance.sh` and `setup-project-wing.sh`):
- Auto-detects working Python 3 interpreter, uses absolute path everywhere
- Removes duplicate project-level MCP entry (was conflicting with user-level)
- Hook errors now log to `~/.mempalace-hook.log` instead of `/dev/null` (silent failures eliminated)
- Wing init errors are visible
- Refuses to use placeholder wing names like `"project-wing-name"`
- Wing seeded with 4 triples on init (project, client, status, tier) so `mempalace_search` returns data immediately

For full symptom→cause→fix reference, see [`playbooks/mempalace-troubleshooting.md`](playbooks/mempalace-troubleshooting.md).

---

## ❓ Troubleshooting

<details>
<summary><strong>MemPalace "not found" error</strong></summary>

```bash
pip3 install mempalace --break-system-packages
python3 -m mempalace init ~/mempalace-data
```
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

Open Claude Code and run:
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

Type in Claude Code: `/compact`
Or start a new session — MemPalace preserves all context.
</details>

<details>
<summary><strong>Browser test needs login</strong></summary>

Tell Claude Code: "Open browser and navigate to [URL]"
Browser opens (headed mode) → you log in manually → tell Claude Code: "Continue testing"
</details>

<details>
<summary><strong>New session lost context</strong></summary>

Type: "Read docs/HANDOFF.md and docs/SESSION.md, then resume"
With MemPalace installed, this happens automatically.
</details>

<details>
<summary><strong>MCP servers show "failed" in project</strong></summary>

If MemPalace shows "failed" at project level but "connected" at user level — that's fine. User-level takes priority. Remove duplicate from project `.mcp.json`:
```bash
echo '{}' > .mcp.json
```
</details>

---

## 🔄 Migrating an existing project from v4.3 → v4.4 LITE

**One command (recommended):**
```bash
cd ~/projects/your-existing-project
bash ~/Desktop/nexalance-kit/migrate-to-v44.sh standard   # or: lite | full
```

The script auto-detects your existing `PROJECT_WING`, `PROJECT_NAME`, and `CLIENT`, backs everything up to `.nexalance-backup-<timestamp>/`, installs the LITE core + playbooks + hooks, upgrades `SESSION.md` to include the Feature Tracker (for Lite/Standard tiers), and runs 6 verification checks before declaring success.

**Idempotent:** running it twice on an already-migrated project aborts safely instead of overwriting.

**Manual fallback (if you prefer step-by-step):**
```bash
cp CLAUDE.md CLAUDE-v4.3-backup.md
cp ~/Desktop/nexalance-kit/NexaLance-CLAUDE-v4.4-LITE.md ./CLAUDE.md
cp -r ~/Desktop/nexalance-kit/playbooks ./playbooks
bash ~/Desktop/nexalance-kit/setup-project-wing.sh "your-wing" "Project Name" "client" standard
```

**Roll back if needed (paths in script output):**
```bash
cp .nexalance-backup-<timestamp>/CLAUDE.md.v43 CLAUDE.md
cp .nexalance-backup-<timestamp>/settings.json.v43 .claude/settings.json
rm -rf playbooks/ .claude/hooks/
```

---

## 📈 Version History

| Version | Lines | Score | Key Addition |
|---------|-------|-------|-------------|
| v2.0 | 415 | 7.2/10 | Basic orchestrator |
| v3.0 | 913 | 9.1/10 | Security, deployment, rollback |
| v4.0 | 1,409 | 9.6/10 | Deep focus, action testing, self-review, memory |
| v4.1 | 1,641 | 9.6/10 | Superpowers + MemPalace + Official plugins |
| v4.2 | 1,793 | 8.4/10 | Playwright CLI + Chrome DevTools |
| v4.3 | 2,350+ | 9.2/10 | Design system, conflict resolution, file organization |
| v4.4 LITE | core ~530 + playbooks ~2,000 | 8.4/10 | Token-optimized: slim core + lazy-loaded playbooks, tiered Phase 0, risk-tiered review, inline self-review, Haiku dispatch (~70% fewer tokens, zero quality compromise) |
| **v4.4 LITE+** | **+ hooks/ + migration** | **9.0/10** | **Post-review hardening: tier-aware feature tracking (Lite/Standard get SESSION.md Feature Tracker), routing enforcement hook (warns if >2 playbooks/turn), cache-break warning hook, idempotent migration script with auto-detection + backup + 6-check verification** |

---

## 🏢 Credits

Built by **NexaLance Agency** — a full-service digital agency delivering 500+ projects across 30+ countries since 2016.

- Website: [nexalance.com](https://nexalance.com)
- Email: info@sorobindu.com

---

## 📄 License

MIT License — free to use, modify, and distribute.

---

*NexaLance Agency — Your Success, Our Mission*
