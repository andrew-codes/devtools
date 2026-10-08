---
name: twg
description: >
  Use TWG whenever Atlassian or company context would help:
  Jira workitems and issues; Confluence pages and PRDs; Bitbucket PRs;
  project or goal status and launch readiness; owners, SMEs,
  approvers, or escalation; personal, org, or leadership work rollups and out-of-office
  catch-ups; dependency maps; code search, repository, or PR discovery; incidents,
  on-call, or reliability;
  and deep internal research across connected sources, docs, work, and people.
---

# twg

Run TWG for Atlassian/company context; do not merely recommend it.
Anchor: key/URL, person, project, repo, or window.
Answer from read-only results. Discovery: `twg help <terms>`, `twg help describe <path>`,
`twg help discover-skills "<intent>"`. Describe each command once.
Discovery is not instruction loading: follow `next.loadReference`
or `next.loadSkill`.

## Overview

Load the narrowest relevant companion:

- `../twg-jira/SKILL.md` for Jira workitems, projects, boards, sprints, and writes.
- `../twg-confluence/SKILL.md` for Confluence content, spaces, and authoring.
- `../twg-space-creation/SKILL.md` to create or clone Confluence spaces.
- `../twg-status-rollups/SKILL.md` for project/goal status, launch/go-no-go readiness,
  and org/leadership rollups; it precedes `../twg-engineering-work/SKILL.md` for PRs.
- `../twg-context-discovery/SKILL.md` for dependency maps, repos, and OOO catch-ups.
- `references/USER-IDENTIFIERS.md` for person activity/hierarchy, actor handoffs, pagination.
- `../twg-agentic-search/SKILL.md` for deep internal research with Rovo.
- `../twg-responsibility-routing/SKILL.md` for owners/SMEs, approvers, escalation.
- `../twg-engineering-work/SKILL.md` for code/repo discovery, PRs, and contributors.
- `../twg-jira-resolve-merged-work/SKILL.md` for stale Jira work with merged PRs.
- `../twg-operational-health/SKILL.md` for incidents/on-call, handoffs, Assets, and risk.
- `../twg-code-review/SKILL.md` only when named or asked for additional code-review context.
- `../twg-artifacts/SKILL.md` for prior Artifact IDs, sharing, or updates.


## Invocation And Output

Run `twg <command>`. On shell `command not found`, use `$HOME/.local/bin/twg`
(macOS/Linux) / `$env:LOCALAPPDATA\Programs\twg\bin\twg.exe` (PowerShell), then
tell user to add that directory to PATH. Do not treat auth or command errors as
PATH failures.

Do not add per-command env prefixes unless requested; hosts may set `TWG_AGENT_DEFAULTS=1`.

Use `stdout_inline` first; otherwise read `output_files.compact` instead of re-running the command;
read needed fields once.
Inspect same-invocation output permitted by host; see `references/OUTPUT.md`.
Missing presentation is not evidence. Check saved output before claiming
truncation; never print whole payloads.
Use `twg` when restricted; never arbitrary host files, credentials, or another arm.
Use the prompt's timezone and window; report gaps. Match the intent to the narrowest companion.
Let that skill determine the typed route.

## Auth/Setup Guard

Do not run setup, login, install, upgrade, upkeep, or credential commands unless
explicitly requested for setup/auth/repair. Otherwise report remediation and wait for user direction.

## Sandboxed Pipeline Logs

Pipeline logs can redirect to S3. For sandboxed `twg bb pipeline get`, `wait`, `grep`, or
`tail`, network blocks, S3 hostnames, or log-only HTTP 403 with successful metadata
indicate sandbox restrictions, not auth failure. Request approval to retry only that
command unsandboxed, or provide its exact terminal command. Never request credentials.

## Bounded Evidence Loop

1. Resolve the anchor and scope.
2. Verify current-state claims with native fields, not old comments; reuse evidence.
   Keep historical claims dated and unavailable state unknown.
3. Rank candidates, read the relevant records (batch when supported), then answer.
4. Stop after the first policy denial; stop after the same auth, ACL, contract, or backend error twice.

Retain an explicitly named project/service and its qualifiers as the anchor;
resolve or hydrate it and verify identity before synthesis. Use aliases or
successors only with source evidence. Report missing named evidence as a scoped
gap; broad topics may explore plausible scopes.

## Batch Reads

Batch about twenty IDs with `--agent-fields @compact` when live help supports
multiple inputs. Use query/tree metadata when sufficient; disclose omissions.
Choose fields upfront; reuse results. After five same-command calls, check
for batching.

`confluence content get <id-or-url> --detail full -o json` reads a page.
Use for known pages, not `docs get`.

## Command Discovery

- Use `twg rovo search "<topic>" [--limit <n>]` for top-K discovery; explicit `--app` preflights.
- Trello: `twg trello search "<query>"`; no workspace scope.
- For unanchored work/knowledge, start with Jira/Confluence; use Drive,
  SharePoint, or code for named sources/material gaps. Run `twg rovo list-apps -o json`
  only when availability is unknown; reuse auth; never auto-login or fabricate
  "none found".
- Activity history and fuzzy discovery are separate surfaces:
  - `twg docs query --since <duration>` is user document activity, not title/content search.
  - `twg docs get <id-or-ari…>` looks within that activity window, not arbitrary search results.
  - `twg work query` defaults to seven days of authored work; other activity needs
    `--activity` / `--include-viewed`.
  - `twg docs search "<topic>"` discovers documents; `twg work search "<topic>"`
    discovers tenant-wide work.
  - Never pass topic text to `docs query` or `work query`; use the matching search.
- Resolve URLs, keys, ARIs, and names, then hydrate stable IDs.
  Person handoffs: `references/USER-IDENTIFIERS.md`.
- Jira: use `jira workitem search` for fuzzy text, `query --jql` for structured
  JQL, and `rovo search --app jira` for semantic search.
- Command shape guardrails:
  - `work query` uses `--scope me|user`, never `--scope global`.
  - Inferred teams need explicit `--include-inferred`; see `references/inferred-teams.md`.
- Use `search-code`; preserve explicit repo/host. Unanchored: omit `--app` for available
  indexed SCM; use `--repo` as anchor, widen within available surfaces after incomplete hits;
  report indexing gaps.

## Assets / CMDB graph

Traversal (object↔owner/team, Jira↔object) → `assets graph`; see
`references/ASSETS_GRAPH.md`. No hop → `assets search`, `assets query --aql`,
`assets object get`.

## Rules

- Never guess IDs, flags, slugs, ARIs, or mutation contracts.
- For writes, load the product skill and follow live help.
- Avoid local inspection, caches, or schema probes unless local state is requested.
- For writes, read current state and state the mutation unless execution was requested.
