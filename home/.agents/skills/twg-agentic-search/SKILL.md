---
name: twg-agentic-search
description: >
  Use with root `twg` for deep iterative enterprise/company knowledge search and
  internal research with Rovo Search across connected apps/connectors including
  Confluence, Jira, Drive, Slack, Bitbucket, and GitHub.
---

# twg-agentic-search

Use together with the root `twg` skill. Exact command grammar comes from live
`twg help`, especially `twg help describe "rovo search"` when filter or output
options matter.

## CLI launcher fallback

Run `twg <command>`. On shell `command not found`, use `$HOME/.local/bin/twg`
(macOS/Linux) / `$env:LOCALAPPDATA\Programs\twg\bin\twg.exe` (PowerShell), then
tell user to add that directory to PATH. Do not treat auth or command errors as
PATH failures.

## Workflow

1. Classify the request as fuzzy or cross-product internal research. Prefer this
   skill when the source is unclear, current company knowledge is needed, or the
   answer may span Confluence, Jira, Drive, Slack, Bitbucket, GitHub, or other
   Rovo-connected apps.
   When the user supplies an exact key, URL, title, or named canonical source,
   preserve that anchor: resolve and verify the returned identity before
   considering similarly named results. A similar title is not a substitute for
   the requested source.
2. Confirm or infer the Atlassian site. Ask only when no configured or explicit
   site is available and the ambiguity would change the search.
3. For unanchored work or knowledge, begin with Jira and Confluence built-ins.
   Expand to Drive, SharePoint, Bitbucket, GitHub, or another connector only
   when the request names that source or the current evidence leaves a material
   gap. If availability is unknown, run
   `twg rovo list-apps -o json`; reuse readiness/auth and do not list apps before
   every query, start setup/login, or fabricate an empty result when unavailable.
4. Start with one query combining the topic and requested artifact or decision.
   Add a focused canonical/authoritative or recent refinement when results mix
   scopes, lack primary sources, or miss the requested time signal. Continue
   only while it can change identity, scope, authority, or freshness. Do not fan
   out exact-title searches for every returned candidate. Follow canonical,
   moved, or superseding source relationships while retaining requested semantics.
5. Choose filters deliberately. Default to Confluence and Jira built-ins for
   official/internal knowledge. Broaden to Slack, Google Drive, SharePoint,
   Bitbucket, GitHub, or other connectors only when useful and available. Use app, type,
   recency, owner/contributor/assignee/reporter/status, title-only, label/space,
   and site filters when they narrow evidence without hiding likely answers.
6. Search with bounded output:

```bash
twg rovo search "<query>" --output json --output-summary auto --agent-fields @compact
twg rovo search "<query>" --output json --output-summary auto --agent-fields @evidence
```

Use `@compact` to shortlist candidates and `@evidence` when snippets, URLs, and
provenance need more detail.

## Evidence Rules

- Treat search snippets as candidates, not facts.
- Treat ranking, recency, activity volume, and similarity as discovery signals,
  not proof of authority, identity, validity, or currentness. Verify the
  selected source's key/URL/title and canonical or supersession relationship
  from hydrated evidence before replacing an explicit anchor.
- Hydrate a small, diverse primary-source set before final claims. For document
  discovery, cover distinct roles such as requirements, architecture/design,
  and current delivery rather than redundant pages. Use product-native
  commands such as `twg confluence content get`, `twg jira workitem get`,
  `twg jira workitem query`, `twg bb pull-requests get <id>`,
  `twg bb repo get`, or the relevant product command for the result URL/type.
  When a native key or URL is known, hydrate it directly; use another search or
  a document-body fetch only when the native result lacks a material field or
  narrative needed for the answer.
- For document or PRD discovery, select a small, diverse set across needed
  roles. Hydrate one per role; add another only for a material conflict, missing
  field, current-delivery question, or requested relationship. Stop when roles,
  current delivery, and conflicts are supported or unavailable.
- Prefer official spaces, owned project pages, current Jira issues, and recent
  decision records over personal drafts or stale chat mentions, unless the user
  explicitly asked for informal signal.
- Compare hydrated evidence for conflicts, recency, ownership, and authority.
- Use one authoritative source when it fully supports the claim. Treat the
  source-count limit as a default, not a quota: add a narrow follow-up only for
  a material unresolved conflict, missing field, or requested relationship.
- Do not rerun an `@evidence` search for a candidate that can be hydrated through
  its product-native URL or ID, or refetch one source under another projection
  merely to increase context. Use a different native projection when it supplies
  a missing material field or relationship, and explain the remaining gap.
  Call out ACL gaps, unavailable connectors, low recall, and unresolved
  contradictions instead of flattening them into a single claim.

## Output

Lead with the answer or best-supported conclusion. Cite hydrated titles/URLs and
include the source app, date or status when available, and why each source was
trusted. Separate confirmed facts, likely interpretations, conflicts, and gaps.
