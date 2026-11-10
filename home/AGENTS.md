# global agent instructions

- Never use the em dash "—". Use plain dash "-" instead.
- When writing commit messages or PR descriptions, NEVER auto-add your agent name as co-author.
- When writing on my behalf, always mimic my voice. For blog posts and long-form essays, use the /write-blog-post skill. For everything else (documentation, PR descriptions, commit messages, etc.), use the /write-as-andrew skill.
- Never manually modify CHANGELOG.md files or any files that are marked as auto-generated.
- When making technical decisions, do not give much weight to development cost.
  Instead, prefer quality, simplicity, robustness, scalability, and long term maintainability.
- For one-off or infrequent operational work, start with the simplest direct end-to-end path.
  Do not build wrappers, control planes, policy layers, custom verifiers, or automation unless the direct path exposes a concrete blocker or repeated need that justifies the added machinery.
- When doing bug fixes, always start with reproducing the bug in an E2E setting as closely aligned with how an end user would experience it as possible.
  This makes sure you find the real problem so your fix will actually solve it.
- When end-to-end testing a product, be picky about the UI you see and be obsessed with pixel perfection.
  If something clearly looks off, even if it is not directly related to what you are doing, try to get it fixed along the way.
- Apply that same high standard to engineering excellence: lint, test failures, and test flakiness.
  If you see one, even if it is not caused by what you are working on right now, still get it fixed.
- Before using "dynamic workflows", "ultra code" or any harness feature that immediately spawns a large swarm of subagents, always explain the tradeoffs and ask the user for explicit approval.
- For anything Atlassian (Jira issues, Confluence pages, search), ALWAYS use the `twg-axi` CLI.
  Never use the `twg` CLI directly. Always use `twg-axi` instead.
  Always favor `twg-axi` over MCP tools. If both have similar tools, always use the `twg-axi` one. Only use MCP tools for those that are geninuely not available in the `twg-axi`.
- When writing content to Confluence, ALWAYS author it as ADF (Atlassian Document Format), never as plain markdown.
  `twg-axi confluence content create/update` has no `adf` format, so pass `--format html`: it is converted to ADF and supports the Confluence-native nodes.
  Run `twg-axi confluence content body-formats html` first and use those constructs instead of plain text where they fit:
  inline smart link cards (`data-card-appearance="inline"`) for links to other Confluence pages, status lozenges, panels, expand blocks, and tables.
  Link to Confluence pages by the site's own host, not another host, so links open in the same tab.
  Do not use `--format md` for new or updated Confluence content.
- When spawned as a Firstmate crewmate, use the firstmate-crew-model-fit skill once near the start of a task to check whether your assigned model fits the task.
- For any screenshot, browser automation, or visual/UI verification task, ALWAYS use the `chrome-devtools-axi` CLI.
  It runs headless by default and captures via the DevTools Protocol, never the real screen.
  If `chrome-devtools-axi` is missing or a command fails, say so and stop - do not fall back to an OS-level screenshot tool.
