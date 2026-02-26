# interknow

Knowledge compounding for Claude Code.

## What this does

interknow is a durable pattern repository — it stores lessons learned from code reviews, debugging sessions, and architectural decisions so they compound across sessions instead of being forgotten.

Each knowledge entry is a markdown file with YAML frontmatter tracking provenance (`independent` vs `primed`), domain tags, evidence anchors (file paths, commit SHAs), and a `lastConfirmed` timestamp. Entries that go 10 reviews without independent confirmation decay to archive, preventing stale knowledge from polluting future sessions.

The plugin includes a qmd MCP server for semantic search across entries, so you can ask "what do we know about database migrations?" and get relevant entries ranked by similarity.

## Installation

First, add the [interagency marketplace](https://github.com/mistakeknot/interagency-marketplace) (one-time setup):

```bash
/plugin marketplace add mistakeknot/interagency-marketplace
```

Then install the plugin:

```bash
/plugin install interknow
```

## Usage

Compound a new pattern after solving a problem:

```
/interknow:compound
```

Or ask naturally:

```
"document what we just learned about SQLite WAL mode"
"save this debugging pattern for next time"
```

Query existing knowledge:

```
/interknow:recall
```

Or:

```
"what do we know about shell portability?"
"recall knowledge about hook timing"
```

## Architecture

```
config/knowledge/
  *.md                   Knowledge entries (markdown + YAML frontmatter)
  archive/               Decayed entries
  README.md              Entry format, provenance rules, decay rules
scripts/
  launch-qmd.sh          qmd MCP server launcher (graceful degradation)
skills/
  compound/SKILL.md      Knowledge entry creation workflow
  recall/SKILL.md        Knowledge query workflow
hooks/
  session-start.sh       Reports knowledge stats at session start
```

## Entry format

```markdown
---
title: Shell stat fallback to epoch zero
domain: shell
provenance: independent
lastConfirmed: 2026-02-20
evidence:
  - path: os/clavain/lib/lib-sprint.sh
    line: 142
---

When `stat` fails on a missing file, fall back to epoch 0 (not current time).
Using current time would skip all staleness checks...
```

## Ecosystem

interknow was extracted from [interflux](https://github.com/mistakeknot/interflux)'s knowledge layer. interflux's `launch-qmd.sh` is now a stub that redirects here.
