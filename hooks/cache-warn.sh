#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Cache-Break Warning — NexaLance v4.4 LITE
# Warns when CLAUDE.md or a playbook is edited mid-session
# (this breaks the prompt cache → next session start = ~6K extra tokens).
# Hook event: PreToolUse, matcher: "Edit|Write|MultiEdit"
# ═══════════════════════════════════════════════════════════════
# Non-blocking: warns only, never blocks.

set -e

INPUT=$(cat 2>/dev/null || echo '{}')

FILE=$(printf '%s' "$INPUT" | python3 -c '
import json, sys
try:
    d = json.loads(sys.stdin.read())
    print(d.get("tool_input", {}).get("file_path", ""))
except Exception:
    pass
' 2>/dev/null)

BASENAME=$(basename "$FILE" 2>/dev/null)

case "$BASENAME" in
    CLAUDE.md)
        echo "" >&2
        echo "⚠️  CACHE WARNING: editing CLAUDE.md mid-session breaks the prompt cache." >&2
        echo "    Next session start = full re-read (~6K extra tokens)." >&2
        echo "    Consider deferring rule changes until between sessions." >&2
        echo "" >&2
        ;;
esac

# Also warn on playbook edits — they are part of the cached context once read
case "$FILE" in
    */playbooks/*.md|playbooks/*.md)
        echo "" >&2
        echo "⚠️  CACHE WARNING: editing $(basename "$FILE") mid-session." >&2
        echo "    If this playbook was already read this session, the cache is now invalidated." >&2
        echo "" >&2
        ;;
esac

exit 0
