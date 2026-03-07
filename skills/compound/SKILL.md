---
description: "Knowledge Compounding (deprecated — use /clavain:compound)"
---

# /interknow:compound — Knowledge Compounding

> **Deprecated:** Knowledge entries have been converged into `docs/solutions/`. Use `/clavain:compound` instead, which writes to `docs/solutions/` with enum-validated schema and provenance tracking.

Extract durable patterns from review findings and save them as knowledge entries.

## When to use

After a flux-drive review completes, or when you discover a reusable pattern worth preserving across sessions.

**Preferred:** Use `/clavain:compound` instead — it writes to `docs/solutions/` with the converged schema (compound docs format + interknow provenance fields).

## Input

Provide either:
- A set of review findings (from flux-drive synthesis)
- A specific pattern or lesson to compound

## Decision Criteria

For each finding, decide: **compound or skip?**

**Compound** (save as knowledge entry) when the finding is:
- A pattern likely to recur in future reviews (not a one-off typo or style nit)
- Backed by concrete evidence (file paths, line numbers, symbol names)
- Generalizable beyond this specific document

**Skip** when:
- The finding is too specific to this one document
- No concrete evidence to anchor it
- Already captured by an existing knowledge entry (check first)

## Knowledge Entry Format

Write markdown files to `${CLAUDE_PLUGIN_ROOT}/config/knowledge/`:

Filename: `{short-kebab-case-description}.md`

```yaml
---
lastConfirmed: {today's date YYYY-MM-DD}
provenance: independent
---
{1-3 sentence finding description, phrased as a generalizable heuristic}

Evidence: {file paths, symbol names, line ranges from the review}
Verify: {1-3 concrete steps to confirm this finding is still valid}
```

## Domain Tagging

If intersense is available, detect the project domain and include it in the finding description. This helps future retrieval prioritize domain-relevant knowledge.

## Provenance Rules

- **NEW finding** (no matching knowledge entry): set `provenance: independent`
- **MATCHES existing entry**: check how it was discovered:
  - Agent independently confirmed → update `lastConfirmed`, set `provenance: independent`
  - Agent had entry in context (primed) → do NOT update `lastConfirmed`

## Sanitization Rules

Before writing ANY entry:
- Remove specific file paths from external repos
- Remove hostnames, internal endpoints, org names, customer identifiers
- Generalize to heuristic form

**Good**: "Auth middleware often swallows context cancellation errors"
**Bad**: "auth.go:47 in ProjectX has a bug"

## Decay Check

After compounding, scan existing entries:
- Read each entry's `lastConfirmed` date
- If not independently confirmed in >60 days, move to `config/knowledge/archive/`
- Log archived entries

## Failure Handling

Compounding is best-effort. If it fails, the review/session is still complete.
