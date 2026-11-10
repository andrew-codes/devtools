#!/usr/bin/env bash
#
# The `work` profile's firstmate, from andrew-codes' fork.
#
#   setup/fork-tools.sh [--firstmate-dir DIR]
#
# What it does, on every run:
#
#   1. ~/developer/firstmate is a clone of andrew-codes/firstmate on `main`.
#      home/bin/firstmate already assumes a checkout lives there.
#   2. The clone is fast-forwarded to the fork's latest `main`.
#
# no-mistakes also comes from andrew-codes' fork, but as a release binary on
# every profile; see setup/no-mistakes.sh.
#
# The clone is guarded. A checkout is left exactly as it is, with a warning
# and the run carrying on, when it:
#
#   - is not a git work tree of its own (a plain directory, or a folder inside
#     some other repository),
#   - has an `origin` that is not the expected fork,
#   - has uncommitted changes (tracked or untracked),
#   - is mid merge/rebase/cherry-pick/revert/bisect,
#   - is not on `main`,
#   - has commits that are not on the fork's `main`, or has diverged from it.
#
# The only things this script ever does to a checkout are `git clone` into a
# path that does not exist yet (or is an empty directory), `git fetch` and
# `git merge --ff-only`. It never commits, resets, checks out, stashes, cleans
# or forces anything.
#
# Where it runs: macOS, from home.nix's installForkTools activation step
# (work profile only, so the personal evaluation has no such step); Windows,
# from setup/windows.sh's Step 7. Nix evaluation stays pure: nothing here runs
# at evaluation time, and the only network use is the clone/fetch above.
#
# Cloning uses HTTPS on purpose. The repository is public, so no
# credentials are involved, and activation (macOS) and a fresh Git Bash
# (Windows) do not have the SSH agent the interactive shell has. Nothing here
# ever embeds a token. An existing clone whose origin is the SSH spelling of
# the same repository is accepted and fetched with whatever it already uses.
#
# Exit status: 0 when every step did what it should (including "already up to
# date"), 3 when at least one step was refused or failed (a warning has been
# printed; the caller turns that into its own end-of-run warning), 2 for bad
# usage.
#
# Sourcing this file with FORK_TOOLS_SOURCE_ONLY=1 defines the functions
# without running anything, which is how the guards are tested against
# throwaway repositories.

set -euo pipefail

FORK_OWNER="andrew-codes"
FORK_BRANCH="main"
# Overridable so the tests can point at local bare repositories. The default is
# the only value that is ever used on a real machine.
FIRSTMATE_URL="${FORK_TOOLS_FIRSTMATE_URL:-https://github.com/$FORK_OWNER/firstmate.git}"

WARNED=0

say() { echo "    $*"; }

warn() {
  WARNED=1
  echo "    WARNING: $*" >&2
}

# Never let git stop to ask for a credential: a hung prompt inside a darwin
# rebuild is worse than a failed fetch.
export GIT_TERMINAL_PROMPT=0

# Lowercase, strip a trailing slash and ".git", and fold the SSH and HTTPS
# spellings of a GitHub URL to "github.com/<owner>/<repo>". Anything that is not
# GitHub is returned lowercased and untouched, which is what lets the tests use
# file:// URLs.
normalize_url() {
  local url
  url="$(printf '%s' "$1" | tr '[:upper:]' '[:lower:]')"
  url="${url%/}"
  url="${url%.git}"
  url="${url%/}"
  case "$url" in
  https://github.com/* | http://github.com/*) url="github.com/${url#*github.com/}" ;;
  ssh://git@github.com/* | ssh://git@github.com:443/*) url="github.com/${url#*github.com*/}" ;;
  git@github.com:*) url="github.com/${url#git@github.com:}" ;;
  esac
  printf '%s' "$url"
}

# sync_checkout <name> <dir> <expected-url>
sync_checkout() {
  local name="$1" dir="$2" url="$3"
  local origin branch head remote

  if [ ! -e "$dir" ] || { [ -d "$dir" ] && [ -z "$(ls -A "$dir" 2>/dev/null)" ]; }; then
    mkdir -p "$(dirname "$dir")"
    say "cloning $name from $url into $dir"
    git clone --quiet --branch "$FORK_BRANCH" "$url" "$dir" ||
      warn "$name: could not clone $url into $dir; skipped"
    return 0
  fi

  if [ ! -d "$dir" ]; then
    warn "$name: $dir exists and is not a directory; left alone"
    return 0
  fi

  # A path that merely sits inside another repository (say ~/developer is
  # itself a work tree) must not be treated as the checkout: every command
  # below would act on the outer repository. `--show-prefix` is empty only at
  # the top of a work tree, and it avoids comparing MSYS and Windows spellings
  # of the same path.
  if ! git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1 ||
    [ -n "$(git -C "$dir" rev-parse --show-prefix 2>/dev/null)" ]; then
    warn "$name: $dir is not the root of a git checkout; left alone"
    return 0
  fi

  origin="$(git -C "$dir" remote get-url origin 2>/dev/null || true)"
  if [ -z "$origin" ] || [ "$(normalize_url "$origin")" != "$(normalize_url "$url")" ]; then
    warn "$name: origin of $dir is '${origin:-<none>}', not $url; left alone"
    return 0
  fi

  # An unfinished merge, rebase, cherry-pick, revert or bisect is work in
  # progress even when the tree happens to look clean.
  local marker
  for marker in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD BISECT_LOG rebase-merge rebase-apply; do
    if [ -e "$(git -C "$dir" rev-parse --git-path "$marker")" ] ||
      [ -e "$dir/$(git -C "$dir" rev-parse --git-path "$marker")" ]; then
      warn "$name: $dir has a $marker in progress; left alone"
      return 0
    fi
  done

  branch="$(git -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null || true)"
  if [ "$branch" != "$FORK_BRANCH" ]; then
    warn "$name: $dir is on '${branch:-a detached HEAD}', not $FORK_BRANCH; left alone"
    return 0
  fi

  if [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]; then
    warn "$name: $dir has uncommitted changes; left alone"
    return 0
  fi

  # Fetch only the one branch into its remote-tracking ref. This is the only
  # step that needs the network; offline, the checkout simply stays as it is.
  if ! git -C "$dir" fetch --quiet origin "+refs/heads/$FORK_BRANCH:refs/remotes/origin/$FORK_BRANCH"; then
    warn "$name: could not fetch origin in $dir; left at its current commit"
    return 0
  fi

  head="$(git -C "$dir" rev-parse HEAD)"
  remote="$(git -C "$dir" rev-parse "refs/remotes/origin/$FORK_BRANCH")"

  if [ "$head" = "$remote" ]; then
    say "$name: already at origin/$FORK_BRANCH ($(git -C "$dir" rev-parse --short HEAD))"
    return 0
  fi

  if git -C "$dir" merge-base --is-ancestor "$head" "$remote"; then
    if git -C "$dir" merge --quiet --ff-only "refs/remotes/origin/$FORK_BRANCH" >/dev/null; then
      say "$name: fast-forwarded to $(git -C "$dir" rev-parse --short HEAD)"
    else
      warn "$name: fast-forward of $dir failed; left at its current commit"
    fi
    return 0
  fi

  if git -C "$dir" merge-base --is-ancestor "$remote" "$head"; then
    warn "$name: $dir has local commits that are not on origin/$FORK_BRANCH; left alone"
  else
    warn "$name: $dir has diverged from origin/$FORK_BRANCH; left alone"
  fi
  return 0
}

main() {
  local firstmate_dir="${HOME}/developer/firstmate"

  while [ $# -gt 0 ]; do
    case "$1" in
    --firstmate-dir) firstmate_dir="${2:?--firstmate-dir needs a value}"; shift 2 ;;
    -h | --help)
      sed -n '3,10p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      return 0
      ;;
    *)
      echo "Error: unknown argument '$1'." >&2
      return 2
      ;;
    esac
  done

  sync_checkout firstmate "$firstmate_dir" "$FIRSTMATE_URL"

  [ "$WARNED" -eq 0 ] || return 3
}

if [ -z "${FORK_TOOLS_SOURCE_ONLY:-}" ]; then
  main "$@"
fi
