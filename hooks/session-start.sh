#!/usr/bin/env bash
# interknow SessionStart hook — report knowledge stats
set -euo pipefail

KNOWLEDGE_DIR="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}/config/knowledge"

if [[ ! -d "$KNOWLEDGE_DIR" ]]; then
    exit 0
fi

# Count active entries (exclude README, archive dir)
count=0
for f in "$KNOWLEDGE_DIR"/*.md; do
    [[ "$(basename "$f")" == "README.md" ]] && continue
    [[ -f "$f" ]] && count=$((count + 1))
done

if (( count == 0 )); then
    exit 0
fi

# Count archived entries
archive_count=0
if [[ -d "$KNOWLEDGE_DIR/archive" ]]; then
    for f in "$KNOWLEDGE_DIR/archive"/*.md; do
        [[ -f "$f" ]] && archive_count=$((archive_count + 1))
    done
fi

msg="interknow: ${count} knowledge entries"
if (( archive_count > 0 )); then
    msg="${msg} (${archive_count} archived)"
fi

cat <<EOF
{"additionalContext": "$msg"}
EOF
