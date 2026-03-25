#!/usr/bin/env bash
# interknow SessionStart hook — report knowledge stats from docs/solutions/
set -uo pipefail
trap 'exit 0' ERR

# Primary: docs/solutions/ (converged knowledge store)
SOLUTIONS_DIR="docs/solutions"
# Legacy fallback: config/knowledge/
KNOWLEDGE_DIR="${CLAUDE_PLUGIN_ROOT:-$(dirname "$(dirname "$0")")}/config/knowledge"

# Count docs/solutions/ entries (exclude INDEX.md, critical-patterns.md, search-surfaces.md)
count=0
if [[ -d "$SOLUTIONS_DIR" ]]; then
    while IFS= read -r -d '' f; do
        name="$(basename "$f")"
        [[ "$name" == "INDEX.md" || "$name" == "critical-patterns.md" || "$name" == "search-surfaces.md" ]] && continue
        count=$((count + 1))
    done < <(find "$SOLUTIONS_DIR" -name "*.md" -print0 2>/dev/null)
fi

# Count legacy entries still in config/knowledge/
legacy_count=0
if [[ -d "$KNOWLEDGE_DIR" ]]; then
    for f in "$KNOWLEDGE_DIR"/*.md; do
        [[ "$(basename "$f")" == "README.md" ]] && continue
        [[ -f "$f" ]] && legacy_count=$((legacy_count + 1))
    done
fi

if (( count == 0 && legacy_count == 0 )); then
    exit 0
fi

msg="interknow: ${count} knowledge entries (docs/solutions/)"
if (( legacy_count > 0 )); then
    msg="${msg}, ${legacy_count} legacy (config/knowledge/)"
fi

cat <<EOF
{"additionalContext": "$msg"}
EOF
