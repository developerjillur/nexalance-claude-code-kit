#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Playbook Tracker — NexaLance v4.4 LITE
# Counts how many playbooks Claude reads per turn. Warns if > 2.
# Hook event: PreToolUse, matcher: "Read"
# ═══════════════════════════════════════════════════════════════
# Non-blocking: always exits 0 so Claude Code never breaks if this fails.

set -e

# Read JSON payload from stdin
INPUT=$(cat 2>/dev/null || echo '{}')

# Extract file_path (use python3 — universally available, no jq dependency)
FILE=$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print(d.get("tool_input", {}).get("file_path", ""))
except Exception:
    pass
' 2>/dev/null)

# Only act on reads of playbooks/*.md
case "$FILE" in
    */playbooks/*.md|playbooks/*.md)
        COUNTER_FILE=".claude/.playbook-counter"
        mkdir -p .claude 2>/dev/null

        CURRENT=$(cat "$COUNTER_FILE" 2>/dev/null || echo 0)
        # Sanity: if file got corrupted, reset
        case "$CURRENT" in
            ''|*[!0-9]*) CURRENT=0 ;;
        esac
        COUNT=$((CURRENT + 1))
        echo "$COUNT" > "$COUNTER_FILE"

        BASENAME=$(basename "$FILE")
        echo "📖 Playbook read #${COUNT} this turn: ${BASENAME}" >&2

        if [ "$COUNT" -gt 2 ]; then
            echo "⚠️  WARNING: ${COUNT} playbooks read this turn." >&2
            echo "    CLAUDE.md rule: typically max 1 per task. Possible token waste." >&2
            echo "    Review whether all reads were necessary." >&2
        fi
        ;;
esac

exit 0
