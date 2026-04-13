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
├── NexaLance-CLAUDE-v4.3-SUPREME.md    ← Master CLAUDE.md template (2,350+ lines)
├── setup-nexalance.sh                   ← One-time machine setup script
├── setup-project-wing.sh                ← Per-project setup script
├── README.md                            ← This file
└── LICENSE                              ← MIT License
```

---

## 🚀 Quick Start (5 minutes)

### Step 1: Clone this repo
```bash
git clone https://github.com/developerjillur/nexalance-claude-code-kit.git ~/Desktop/nexalance-kit
cd ~/Desktop/nexalance-kit
chmod +x setup-nexalance.sh setup-project-wing.sh
```

### Step 2: Run machine setup (one time only)
```bash
bash setup-nexalance.sh
```
This installs: Superpowers, MemPalace, Code Review, Feature Dev, Frontend Design, Playwright CLI, Chrome DevTools MCP, Vercel Design Guidelines, and auto-save hooks.

### Step 3: Set up your first project
```bash
mkdir -p ~/projects/my-project && cd ~/projects/my-project

# Copy the master CLAUDE.md
cp ~/Desktop/nexalance-kit/NexaLance-CLAUDE-v4.3-SUPREME.md ./CLAUDE.md

# Initialize project with isolated memory wing
bash ~/Desktop/nexalance-kit/setup-project-wing.sh "my-project" "My Awesome Project" "client-name"

# Add your PRD
# Put your Product Requirements Document in docs/PRD.md

# Open in VS Code
code .
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

## 📈 Version History

| Version | Lines | Score | Key Addition |
|---------|-------|-------|-------------|
| v2.0 | 415 | 7.2/10 | Basic orchestrator |
| v3.0 | 913 | 9.1/10 | Security, deployment, rollback |
| v4.0 | 1,409 | 9.6/10 | Deep focus, action testing, self-review, memory |
| v4.1 | 1,641 | 9.6/10 | Superpowers + MemPalace + Official plugins |
| v4.2 | 1,793 | 8.4/10 | Playwright CLI + Chrome DevTools |
| **v4.3** | **2,350+** | **9.2/10** | Design system, conflict resolution, file organization |

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
