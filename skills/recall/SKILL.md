# /interknow:recall — Knowledge Recall

Query the knowledge base for patterns relevant to a topic or question.

## When to use

- Before starting a review, to see what patterns are known
- When investigating a bug, to check for similar past findings
- When a domain is detected, to surface domain-relevant knowledge

## Steps

### 1. Check qmd availability

Test if qmd MCP server is available by calling `qmd:status`. If unavailable, fall back to file-based search.

### 2. Build query

Compose a semantic query from:
- The user's topic or question
- Project domain (from `.claude/intersense.yaml` if available)
- File paths or symbols mentioned

### 3. Search knowledge

**With qmd:** Use `qmd:vsearch` against the knowledge directory:
```
qmd:vsearch query="<semantic query>" path="${CLAUDE_PLUGIN_ROOT}/config/knowledge" top_k=10
```

**Without qmd (fallback):** Read all `config/knowledge/*.md` files and filter by keyword matching.

### 4. Filter and rank

- Exclude archived entries (in `config/knowledge/archive/`)
- Prioritize entries with recent `lastConfirmed` dates
- Prioritize `provenance: independent` over `provenance: primed`
- Cap at top 5 results

### 5. Present results

For each matching entry, show:
- **Title** (from filename)
- **Finding** (first paragraph of body)
- **Last confirmed** date
- **Provenance** status

If no matches found: "No knowledge entries match this query."

## Output format

```
## Knowledge Recall: {query summary}

### 1. {entry-title}
{finding description}
Last confirmed: {date} | Provenance: {independent|primed}

### 2. {entry-title}
...

---
{N} entries searched, {M} matches found.
```
