#!/usr/bin/env bash
#
# Installs the third-party agent skills listed in third-party-skills.txt at their
# pinned refs, and removes ones that were dropped from the list.
#
#   setup/third-party-skills.sh [--manifest FILE] [--home DIR]
#
# Skills land in the real directory ~/.agents/skills (the `skills` CLI's own
# location, read by pi and Codex) and are linked into ~/.claude/skills. Neither
# is a link into this repo, so nothing a third party writes can dirty the
# checkout; the repo's own skills/ are linked in one by one instead.
#
# What was installed is recorded in ~/.local/state/devtools/third-party-skills,
# one `<skill> <source> <ref>` per line. An entry that is already recorded and
# still on disk is skipped, so a rebuild without a manifest change costs nothing
# and needs no network. A failed install warns and is retried next time.
#
# Exit status: 0 on success, 3 when something failed (a warning has been
# printed), 2 for bad usage.

set -euo pipefail

SKILLS_CLI_VERSION="1.8.0" # npm: skills

manifest="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/third-party-skills.txt"
home_dir="$HOME"
while [ $# -gt 0 ]; do
  case "$1" in
  --manifest) manifest="${2:?--manifest needs a value}"; shift 2 ;;
  --home) home_dir="${2:?--home needs a value}"; shift 2 ;;
  -h | --help) sed -n '3,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "Error: unknown argument '$1'." >&2; exit 2 ;;
  esac
done
[ -f "$manifest" ] || { echo "Error: $manifest not found." >&2; exit 2; }

failed=0
warn() { failed=1; echo "    WARNING: third-party skills: $*" >&2; }

state="$home_dir/.local/state/devtools/third-party-skills"
mkdir -p "$(dirname "$state")"
touch "$state"
skills() {
  HOME="$home_dir" DISABLE_TELEMETRY=1 npx --yes "skills@$SKILLS_CLI_VERSION" "$@" </dev/null
}

declare -a wanted=()
while read -r source ref skill extra; do
  case "$source" in '' | '#'*) continue ;; esac
  if [ -z "${skill:-}" ] || [ -n "${extra:-}" ]; then
    warn "bad manifest line for '$source'; expected '<owner/repo> <git ref> <skill>'"
    continue
  fi
  entry="$skill $source $ref"
  wanted+=("$entry")
  if grep -Fxq "$entry" "$state" && [ -e "$home_dir/.agents/skills/$skill" ]; then
    continue
  fi
  if skills add "$source#$ref" -s "$skill" -g -y -a codex claude-code >/dev/null; then
    grep -Fxv -e "$entry" "$state" | awk -v s="$skill" '$1 != s' >"$state.new" || true
    echo "$entry" >>"$state.new"
    mv -f "$state.new" "$state"
    echo "    skill $skill installed ($source@${ref:0:12})"
  else
    warn "could not install $skill from $source#$ref"
  fi
done <"$manifest"

# Remove skills that were installed from an entry that is no longer listed.
mapfile -t recorded <"$state"
for line in "${recorded[@]+"${recorded[@]}"}"; do
  read -r skill source ref <<<"$line"
  [ -n "$skill" ] || continue
  keep=0
  for w in ${wanted[@]+"${wanted[@]}"}; do [ "$w" = "$skill $source $ref" ] && keep=1; done
  [ "$keep" -eq 1 ] && continue
  if skills remove "$skill" -g -y >/dev/null; then
    grep -Fxv -e "$skill $source $ref" "$state" >"$state.new" || true
    mv -f "$state.new" "$state"
    echo "    skill $skill removed (no longer in the manifest)"
  else
    warn "could not remove $skill"
  fi
done

[ "$failed" -eq 0 ] || exit 3
