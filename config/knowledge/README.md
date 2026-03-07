# Knowledge Layer (Deprecated)

> **Deprecated:** Knowledge entries have been converged into `docs/solutions/` (see Demarch-7xs, PHILOSOPHY.md § Memory Architecture). All 8 entries from this directory have been migrated to `docs/solutions/best-practices/`. New entries should be created via `/clavain:compound`, which writes to `docs/solutions/` with the converged schema.
>
> This directory is kept as a read-only archive. Do not add new entries here.

Knowledge entries discovered during reviews. Each file is a markdown document with YAML frontmatter. Canonical location: `docs/solutions/` (was interknow `config/knowledge/`, was interflux `config/flux-drive/knowledge/`).

## Entry format

```yaml
---
lastConfirmed: 2026-02-10
provenance: independent
---
Auth middleware swallows context cancellation errors.
Both Safety agent and Oracle flagged this independently.

Evidence: middleware/auth.go:47-52, handleRequest(): context.Err() not checked after upstream call.
Verify: grep for ctx.Err() after http.Do() calls in middleware/*.go.
```

### Frontmatter fields

| Field | Values | Purpose |
|-------|--------|---------|
| `lastConfirmed` | ISO date (YYYY-MM-DD) | Last time this finding was independently re-observed |
| `provenance` | `independent` or `primed` | Whether the confirming agent had this entry in context |

### Body requirements

- **Finding description**: 1-3 sentences describing the pattern or issue
- **Evidence anchors**: File paths, symbol names, line ranges: concrete pointers to the finding
- **Verification steps**: 1-3 steps to confirm the finding is still valid

Entries without evidence anchors rot into unverifiable folklore. Always include concrete pointers.

## Provenance rules

The `provenance` field prevents a **false-positive feedback loop**:

```
Finding compounded → injected into next review → agent re-confirms (primed)
→ lastConfirmed updated → entry never decays → false positive permanent
```

- **`independent`**: Agent flagged this WITHOUT seeing the knowledge entry (genuine re-confirmation). Updates `lastConfirmed`.
- **`primed`**: Agent had this entry in its context when it re-flagged it (not a true confirmation). Does NOT update `lastConfirmed`.

Only independent confirmations refresh the decay timer.

## Decay rules

Two independent decay triggers (whichever fires first):

- **Review-count decay:** Entries not independently confirmed in **10 reviews** get archived
- **Time-based decay:** Entries with `lastConfirmed` older than **180 days** get archived (staleness check)

Both rules follow intermem's standard pattern: grace period (first 10 reviews or 180 days) → linear decay → hysteresis (require 2 consecutive staleness checks before archival to prevent single-sweep false positives).

- Archived entries are moved to `config/knowledge/archive/` (or `docs/solutions/archive/` for converged entries)
- Archive preserves the full entry for future reference

## Sanitization rules

Global entries must be phrased as **generalized heuristics**. Never store:
- File paths to specific repos (outside Clavain)
- Hostnames or internal endpoints
- Organization names or customer identifiers
- Secrets or credentials
- Vulnerability details with exploitable specifics

**Good**: "Auth middleware often swallows context cancellation errors: check for ctx.Err() after upstream calls"
**Bad**: "middleware/auth.go in Project X has a bug at line 47"

## Manual retraction

To retract a wrong entry: delete the file. Knowledge entries are just markdown files.

Future: `/interknow:review` command for inspection, confirmation, and retraction.

## Retrieval

Knowledge is retrieved via qmd semantic search (interknow's MCP server) during flux-drive reviews:
- Cap: 5 entries per agent
- Query: agent domain keywords + document summary
- Pipelined with agent launch (not during triage)
- If qmd unavailable, agents run without knowledge injection
