---
name: create-subagent
description: >-
  Use when the user wants to create, add, or change a subagent (a named agent with its own prompt that
  pi, Claude Code and Codex can delegate to) in the devtools repo. Walks through the agent's purpose,
  name, description and prompt, asks which tools it applies to and the per-tool details (model, tool
  list, sandbox), then writes the tool-neutral source and the per-tool layers. Not for installing
  someone else's skill: use install-skill for that.
disable-model-invocation: false
---

# Create a subagent

Subagents live in the devtools repo (`andrew-codes/devtools`, usually checked out at `~/.dotfiles`) as a
tool-neutral source plus one small layer per tool. `setup/subagents.sh` combines them into each tool's
own file on every `devtools-rebuild`. Read `setup/subagents.sh` and the three layer files first if
anything below looks out of date; they are the source of truth for the format.

```
subagents/<name>.md             name, description, prompt body. No model, no tools.
subagents/layers/claude.yaml   -> ~/.claude/agents/<name>.md
subagents/layers/pi.yaml       -> ~/.pi/agent/agents/<name>.md
subagents/layers/codex.yaml    -> ~/.codex/agents/<name>.toml
```

A layer is YAML: one block per agent, keyed by agent name, with scalar settings. For Claude Code and pi each
key becomes a frontmatter line `key: value`; for Codex it becomes `key = "value"`. `skip: true` in the
agent's block keeps it out of that tool. Keep `tools` as one comma-separated string.

```yaml
code-reviewer:
  model: opus
  tools: Read, Grep, Glob, Bash
```

## 1. Work out what the subagent is

Ask the user, one short question at a time, and stop asking once you can write it:

- **Purpose.** What job does it do, and what should it never do? A subagent that does one job well is
  worth more than a general one.
- **Name.** Lowercase, hyphenated, matching the file name: `<name>.md`. Check `subagents/` for a clash.
- **Description.** One or two sentences that say when to use it and when not to (naming the agent to use
  instead). The calling agent decides from this alone, so lead with the trigger.
- **Prompt body.** Its working method, not a personality. Name the steps, what to report, and what it
  must not touch. Keep it as short as the job allows.
- **Read-only or editing?** This decides tool lists and the Codex sandbox.

## 2. Ask which tools it applies to

Ask which of pi, Claude Code and Codex should get it. Default to all three. For each tool that is not
wanted, add a `<name>:` block with `skip: true` to that tool's layer (an unlisted agent is still generated, with no model or
tool restriction, so skipping must be explicit).

## 3. Collect the per-tool details

- **Claude Code** (`claude.yaml`): `model` is `opus`, `sonnet`, `haiku`, `inherit` or a full Claude
  model id; `tools` is a comma list of Claude tool names (`Read, Write, Edit, Bash, Glob, Grep,
  WebFetch, WebSearch`, or `mcp__...` names). Omit `tools` for all tools.
- **pi** (`pi.yaml`): `model` is `provider/id` or a fuzzy name such as `sonnet` or `opus`; `tools` uses
  pi's built-ins `read, bash, edit, write, grep, find, ls` (so `Glob` is `find`). pi has no built-in
  web tools. Omit `tools` for all.
- **Codex** (`codex.yaml`): there is no per-agent tool list, and Anthropic model names mean nothing
  to it, so normally write nothing. Add `sandbox_mode: read-only` to its block for an agent that must not edit.
  Add `model: <openai id>` only if the user wants a specific Codex model.

If the user does not know a model, suggest `sonnet` for routine work and `opus` for review, debugging or
security reasoning, and say it is a suggestion.

## 4. Write it

Work in the devtools checkout on a branch, not directly on the default branch.

1. Write `subagents/<name>.md`. Frontmatter is only `name` and `description` (quote the description if it
   contains a colon), then `---`, a blank line, and the prompt body.
2. Append a `<name>:` block to each wanted tool's layer file (`subagents/layers/<tool>.yaml`).
3. Run `bash setup/subagents.sh --home "$(mktemp -d)"` and confirm the summary lines count the new agent
   for every wanted tool. This writes into a scratch directory, not the real home.
4. Run `shellcheck` only if you changed a script. Do not run `devtools-rebuild` yourself.

## 5. Tell the user how to apply it

State what you wrote (the file and the layer blocks) and that the subagent arrives with the next
`devtools-rebuild` on macOS (or `setup/windows.sh` on Windows) once the change is merged, and that it
needs no other setup. An agent with the same name already in `~/.codex/agents`, `~/.claude/agents` or
`~/.pi/agent/agents` that this repo did not generate is left alone, so a name clash shows up as a
"left alone" count in the rebuild output rather than as an overwrite.

## Changing or removing one

Edit the same files. To remove an agent, delete `subagents/<name>.md` and its layer blocks; the next
rebuild deletes the files it generated.
