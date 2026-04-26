#!/usr/bin/env bash
# ═══════════════════════════════════════════════════════════════
# Reset Counter — NexaLance v4.4 LITE
# Resets playbook counter at the start of each user prompt
# (each prompt = new task = counter resets to 0).
# Hook event: UserPromptSubmit
# ═══════════════════════════════════════════════════════════════

# Non-blocking: always exits 0
rm -f .claude/.playbook-counter 2>/dev/null
exit 0
