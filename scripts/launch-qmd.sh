#!/usr/bin/env bash
# Launcher for qmd MCP server: checks if qmd is installed before starting.
# On a new machine, qmd may not be available — emit a helpful error instead
# of letting Claude Code fail silently.
set -euo pipefail

# Ensure bun global bin is on PATH (not inherited in MCP server processes)
for _bindir in "$HOME/.bun/bin" "$HOME/.local/bin"; do
    [[ -d "$_bindir" ]] && PATH="$_bindir:$PATH"
done

if ! command -v qmd &>/dev/null; then
    echo "qmd not found. interknow will work without it but semantic knowledge search will be unavailable." >&2
    echo "To install: build qmd from source and place the binary on your PATH." >&2
    # Exit cleanly so Claude Code doesn't retry in a loop
    exit 0
fi

exec qmd "$@"
