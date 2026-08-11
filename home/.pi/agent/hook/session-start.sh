#!/usr/bin/env bash
# Shared session-start actions for both agent harnesses.
#
# Single source of truth: pi invokes this from hooks.yaml (session.created) and
# Claude Code invokes it from ~/.claude/settings.json (SessionStart). Keep the
# behaviour here, not duplicated in either harness config.
#
# Every step is best-effort (|| true): a missing tool or a non-repo cwd must not
# fail the hook or block the session from starting.

# Warm up the axi tool binaries so their first real invocation is fast.
for tool in gh-axi chrome-devtools-axi quota-axi npm-axi lavish-axi tasks-axi; do
  "$HOME/.volta/bin/$tool" --version >/dev/null 2>&1 || true
done

# `no-mistakes init` is idempotent (refreshes an existing gate rather than
# erroring), so it is safe on every session start. Only inside a git repo.
if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  "$HOME/go/bin/no-mistakes" init >/dev/null 2>&1 || true
fi
