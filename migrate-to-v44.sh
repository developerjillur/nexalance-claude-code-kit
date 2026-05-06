#!/bin/bash
# ═══════════════════════════════════════════════════════════════
# NexaLance — Migrate Existing Project from v4.3 → v4.4 LITE
# Safe, idempotent migration with auto-detection and backup.
# Usage:  bash migrate-to-v44.sh [TIER]
#         (run from inside your project directory)
#         TIER: lite | standard | full   (default: standard)
# ═══════════════════════════════════════════════════════════════

set -e

# Colors
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
NC='\033[0m'

success() { echo -e "${GREEN}✅ $1${NC}"; }
warn()    { echo -e "${YELLOW}⚠️  $1${NC}"; }
fail()    { echo -e "${RED}❌ $1${NC}"; }
info()    { echo -e "${BLUE}ℹ️  $1${NC}"; }

TIER=${1:-standard}

# Validate tier
case "$TIER" in
    lite|standard|full) ;;
    *)
        fail "Invalid tier: '$TIER'. Must be: lite | standard | full"
        echo "Usage: bash migrate-to-v44.sh [lite|standard|full]"
        exit 1
        ;;
esac

echo "═══════════════════════════════════════════════════════════"
echo "🔄 NexaLance Migration: v4.3 → v4.4 LITE (tier: $TIER)"
echo "═══════════════════════════════════════════════════════════"
echo ""

# ─── Step 1: Locate the kit ───
echo "📋 Step 1: Locating nexalance-kit installation..."

KIT_DIR=""
for candidate in \
    "$HOME/Desktop/nexalance-kit" \
    "$HOME/nexalance-kit" \
    "$HOME/Desktop/NexaLance All Projects/nexalance-kit" \
    "$(dirname "$0")"; do
    if [ -f "$candidate/NexaLance-CLAUDE-v4.4-LITE.md" ] && [ -d "$candidate/playbooks" ]; then
        KIT_DIR=$(cd "$candidate" && pwd)
        break
    fi
done

if [ -z "$KIT_DIR" ]; then
    fail "Could not locate nexalance-kit (looked for v4.4-LITE template + playbooks/)."
    echo "    Set KIT_DIR manually:"
    echo "    KIT_DIR=/path/to/nexalance-kit bash migrate-to-v44.sh $TIER"
    exit 1
fi
success "Found kit at: $KIT_DIR"

# ─── Step 2: Verify we're in a project (must have CLAUDE.md) ───
echo ""
echo "📋 Step 2: Verifying current directory is a v4.x project..."

if [ ! -f "CLAUDE.md" ]; then
    fail "No CLAUDE.md in current directory. Run this from your project root."
    echo "    Or for a fresh project:"
    echo "    cp $KIT_DIR/NexaLance-CLAUDE-v4.4-LITE.md ./CLAUDE.md"
    exit 1
fi

# Detect existing version
if grep -q "v4.4 LITE" CLAUDE.md; then
    warn "Project is already on v4.4 LITE. Migration would overwrite — aborting."
    echo "    To force re-install, delete CLAUDE.md first."
    exit 0
fi

if grep -q "v4.3" CLAUDE.md || grep -q "SUPREME" CLAUDE.md; then
    info "Detected v4.3 (SUPREME/FINAL) project — proceeding with migration."
else
    warn "Could not confirm v4.3. Continuing, but verify backup before proceeding."
fi

# ─── Step 3: Detect existing PROJECT_WING / PROJECT_NAME / CLIENT ───
echo ""
echo "📋 Step 3: Auto-detecting existing project identity..."

DETECTED_WING=$(grep -E '^PROJECT_WING:' CLAUDE.md | head -1 | sed -E 's/.*PROJECT_WING:[[:space:]]*"([^"]*)".*/\1/' || echo "")
DETECTED_NAME=$(grep -E '^PROJECT_NAME:' CLAUDE.md | head -1 | sed -E 's/.*PROJECT_NAME:[[:space:]]*"([^"]*)".*/\1/' || echo "")
DETECTED_CLIENT=$(grep -E '^CLIENT:' CLAUDE.md | head -1 | sed -E 's/.*CLIENT:[[:space:]]*"([^"]*)".*/\1/' || echo "")

if [ -z "$DETECTED_WING" ]; then
    fail "Could not detect PROJECT_WING in CLAUDE.md. Manual migration required."
    exit 1
fi

success "Detected:"
echo "    PROJECT_WING:  $DETECTED_WING"
echo "    PROJECT_NAME:  $DETECTED_NAME"
echo "    CLIENT:        ${DETECTED_CLIENT:-unspecified}"
echo "    NEW TIER:      $TIER"

# ─── Step 4: Backup current state ───
echo ""
echo "📋 Step 4: Backing up current state..."

TS=$(date +%Y%m%d-%H%M%S)
BACKUP_DIR=".nexalance-backup-$TS"
mkdir -p "$BACKUP_DIR"

cp CLAUDE.md "$BACKUP_DIR/CLAUDE.md.v43" 2>/dev/null || true
[ -f .claude/settings.json ] && cp .claude/settings.json "$BACKUP_DIR/settings.json.v43" 2>/dev/null
[ -d docs ] && cp -r docs "$BACKUP_DIR/docs.v43" 2>/dev/null

success "Backup created at: $BACKUP_DIR/"

# ─── Step 5: Install v4.4 LITE template + playbooks ───
echo ""
echo "📋 Step 5: Installing v4.4 LITE template + playbooks..."

cp "$KIT_DIR/NexaLance-CLAUDE-v4.4-LITE.md" CLAUDE.md
success "CLAUDE.md replaced with v4.4 LITE core"

if [ -d playbooks ]; then
    warn "Existing playbooks/ folder found — backing up to $BACKUP_DIR/playbooks.v43/"
    mv playbooks "$BACKUP_DIR/playbooks.v43"
fi
cp -r "$KIT_DIR/playbooks" ./playbooks
success "playbooks/ folder installed ($(ls playbooks/*.md | wc -l | tr -d ' ') files)"

# ─── Step 6: Re-run setup-project-wing.sh to merge identity + tier + hooks ───
echo ""
echo "📋 Step 6: Re-applying project wing config + tier + hooks..."

bash "$KIT_DIR/setup-project-wing.sh" "$DETECTED_WING" "$DETECTED_NAME" "${DETECTED_CLIENT:-unspecified}" "$TIER"

# ─── Step 7: SESSION.md upgrade — preserve history, ensure Feature Tracker for Lite/Standard ───
echo ""
echo "📋 Step 7: Upgrading SESSION.md (preserving history)..."

if [ -f docs/SESSION.md ] && [ "$TIER" != "full" ]; then
    if ! grep -q "Feature Tracker" docs/SESSION.md; then
        # Inject Feature Tracker section before "Session History"
        TEMP=$(mktemp)
        python3 << PYEOF
import re

with open("docs/SESSION.md", "r") as f:
    content = f.read()

tracker_block = """
## Feature Tracker ($TIER tier — replaces FEATURES.md)
| ID | Feature | Priority | Status | Files | Tested ✅ | Working ✅ | Notes |
|----|---------|----------|--------|-------|-----------|-----------|-------|
| F-001 | _(populate from PRD or pre-existing FEATURES.md)_ | - | ⏳ pending | - | ❌ | ❌ | - |

Status legend: ⏳ pending | 🚧 in progress | ✅ done | ⚠️ blocked

> On every feature completion, update the row's Status, Files, Tested, Working columns.
> This table IS the single source of truth for feature progress in $TIER-tier projects.

"""

# Insert before "## Session History" if present, else append
if "## Session History" in content:
    content = content.replace("## Session History", tracker_block + "## Session History", 1)
else:
    content += tracker_block

with open("docs/SESSION.md", "w") as f:
    f.write(content)
PYEOF
        success "Feature Tracker section added to existing SESSION.md"
    else
        info "SESSION.md already has Feature Tracker — left untouched"
    fi
fi

# If existing project has FEATURES.md and we're on Lite/Standard, suggest copying rows
if [ -f docs/FEATURES.md ] && [ "$TIER" != "full" ]; then
    warn "docs/FEATURES.md exists but tier is $TIER (no longer used)."
    echo "    Manual step: copy feature rows from docs/FEATURES.md → docs/SESSION.md → Feature Tracker."
    echo "    Then: rm docs/FEATURES.md  (or keep as archive)"
fi

# ─── Step 8: Verify ───
echo ""
echo "📋 Step 8: Verifying migration..."

CHECKS_PASSED=0
CHECKS_TOTAL=8

[ -f CLAUDE.md ] && grep -q "v4.4 LITE" CLAUDE.md && { success "CLAUDE.md is v4.4 LITE"; CHECKS_PASSED=$((CHECKS_PASSED+1)); } || fail "CLAUDE.md is not v4.4 LITE"
PB_COUNT=$(ls playbooks/*.md 2>/dev/null | wc -l | tr -d ' ')
[ -d playbooks ] && [ "$PB_COUNT" -ge 11 ] && { success "playbooks/ has $PB_COUNT files (≥11 required)"; CHECKS_PASSED=$((CHECKS_PASSED+1)); } || fail "playbooks/ incomplete (have $PB_COUNT, need ≥11)"
[ -d .claude/hooks ] && [ -x .claude/hooks/playbook-tracker.sh ] && { success ".claude/hooks/ installed"; CHECKS_PASSED=$((CHECKS_PASSED+1)); } || fail "hooks not installed"
[ -f .claude/hooks/wiki-ingest.py ] && { success "wiki-ingest.py installed"; CHECKS_PASSED=$((CHECKS_PASSED+1)); } || fail "wiki-ingest.py missing"
[ -f .claude/settings.json ] && grep -q "playbook-tracker" .claude/settings.json && grep -q "wiki-ingest" .claude/settings.json && { success "hooks wired in settings.json (incl. wiki-ingest)"; CHECKS_PASSED=$((CHECKS_PASSED+1)); } || fail "hooks not fully wired"
grep -q "PROJECT_TIER" CLAUDE.md && { success "PROJECT_TIER set"; CHECKS_PASSED=$((CHECKS_PASSED+1)); } || fail "PROJECT_TIER missing"
[ -f docs/SESSION.md ] && { success "SESSION.md preserved/updated"; CHECKS_PASSED=$((CHECKS_PASSED+1)); } || fail "SESSION.md missing"
[ -f docs/wiki/CLAUDE.md ] && [ -f docs/wiki/index.md ] && { success "docs/wiki/ scaffolded (CLAUDE.md + index.md)"; CHECKS_PASSED=$((CHECKS_PASSED+1)); } || fail "docs/wiki/ not scaffolded"

echo ""
echo "═══════════════════════════════════════════════════════════"
if [ "$CHECKS_PASSED" = "$CHECKS_TOTAL" ]; then
    success "MIGRATION COMPLETE — $CHECKS_PASSED/$CHECKS_TOTAL checks passed"
else
    warn "MIGRATION PARTIAL — $CHECKS_PASSED/$CHECKS_TOTAL checks passed (review above)"
fi
echo "═══════════════════════════════════════════════════════════"

echo ""
echo "📝 Next steps:"
echo "   1. Review the diff:  git diff CLAUDE.md docs/SESSION.md"
echo "   2. If tier is lite/standard and you had docs/FEATURES.md:"
echo "      → copy feature rows into docs/SESSION.md → Feature Tracker"
echo "      → optionally archive: mv docs/FEATURES.md $BACKUP_DIR/"
echo "   3. Test in Claude Code: open project, type 'Continue'"
echo "   4. Verify hooks fire: read a playbook, see playbook-tracker output in stderr"
echo "   5. LLM Wiki backfill ran during setup — check docs/wiki/raw/discussions/"
echo "      for converted session transcripts. Synthesis happens on demand"
echo "      next time you ask Claude a domain/recall question."
echo ""
echo "🔙 Rollback (if needed):"
echo "   cp $BACKUP_DIR/CLAUDE.md.v43 CLAUDE.md"
echo "   cp $BACKUP_DIR/settings.json.v43 .claude/settings.json"
echo "   rm -rf playbooks/ .claude/hooks/ docs/wiki/"
echo ""
