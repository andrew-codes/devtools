#!/usr/bin/env bash
#
# The `work` profile's firstmate and no-mistakes, both from andrew-codes' forks.
#
#   setup/fork-tools.sh [--firstmate-dir DIR] [--no-mistakes-dir DIR]
#                       [--gobin DIR] [--state-dir DIR]
#
# What it does, on every run:
#
#   1. ~/developer/firstmate is a clone of andrew-codes/firstmate on `main`.
#      home/bin/firstmate already assumes a checkout lives there.
#   2. ~/.local/share/devtools/no-mistakes is a clone of
#      andrew-codes/no-mistakes on `main` (a stable place outside this repo).
#   3. Each clone is fast-forwarded to the fork's latest `main`.
#   4. no-mistakes is built from that clone and installed into the Go bin
#      directory (~/go/bin, the same place the personal profile's pinned
#      `go install` puts it, and already on PATH), but only when the clone's
#      commit changed or the installed binary is not the one built last time.
#
# Both clones are guarded. A checkout is left exactly as it is, with a warning
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
# at evaluation time, and the only network use is the clone/fetch above and
# Go's module downloads while building.
#
# Cloning uses HTTPS on purpose. Both repositories are public, so no
# credentials are involved, and activation (macOS) and a fresh Git Bash
# (Windows) do not have the SSH agent the interactive shell has. Nothing here
# ever embeds a token. An existing clone whose origin is the SSH spelling of
# the same repository is accepted and fetched with whatever it already uses.
#
# Exit status: 0 when every step did what it should (including "already up to
# date"), 3 when at least one step was refused or failed (a warning has been
# printed; the caller turns that into its own end-of-run warning), 2 for bad
# usage. A refusal never stops the other tool from being handled.
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
NO_MISTAKES_URL="${FORK_TOOLS_NO_MISTAKES_URL:-https://github.com/$FORK_OWNER/no-mistakes.git}"

# The import path the fork's go.mod still declares (a fork keeps its upstream's
# module path), which is what its -X ldflags have to name.
NO_MISTAKES_BUILDINFO="github.com/kunchenguid/no-mistakes/internal/buildinfo"

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

# Result of the last sync_checkout, read by the caller:
#   cloned | updated | unchanged   the checkout is at the fork's main
#   refused                        a guard fired; nothing was touched
#   failed                         clone or fetch did not work
SYNC_RESULT=""

# sync_checkout <name> <dir> <expected-url>
sync_checkout() {
  local name="$1" dir="$2" url="$3"
  local origin branch head remote

  SYNC_RESULT=failed

  if [ ! -e "$dir" ] || { [ -d "$dir" ] && [ -z "$(ls -A "$dir" 2>/dev/null)" ]; }; then
    mkdir -p "$(dirname "$dir")"
    say "cloning $name from $url into $dir"
    if git clone --quiet --branch "$FORK_BRANCH" "$url" "$dir"; then
      SYNC_RESULT=cloned
    else
      warn "$name: could not clone $url into $dir; skipped"
    fi
    return 0
  fi

  if [ ! -d "$dir" ]; then
    warn "$name: $dir exists and is not a directory; left alone"
    SYNC_RESULT=refused
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
    SYNC_RESULT=refused
    return 0
  fi

  origin="$(git -C "$dir" remote get-url origin 2>/dev/null || true)"
  if [ -z "$origin" ] || [ "$(normalize_url "$origin")" != "$(normalize_url "$url")" ]; then
    warn "$name: origin of $dir is '${origin:-<none>}', not $url; left alone"
    SYNC_RESULT=refused
    return 0
  fi

  # An unfinished merge, rebase, cherry-pick, revert or bisect is work in
  # progress even when the tree happens to look clean.
  local marker
  for marker in MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD BISECT_LOG rebase-merge rebase-apply; do
    if [ -e "$(git -C "$dir" rev-parse --git-path "$marker")" ] ||
      [ -e "$dir/$(git -C "$dir" rev-parse --git-path "$marker")" ]; then
      warn "$name: $dir has a $marker in progress; left alone"
      SYNC_RESULT=refused
      return 0
    fi
  done

  branch="$(git -C "$dir" symbolic-ref --short -q HEAD 2>/dev/null || true)"
  if [ "$branch" != "$FORK_BRANCH" ]; then
    warn "$name: $dir is on '${branch:-a detached HEAD}', not $FORK_BRANCH; left alone"
    SYNC_RESULT=refused
    return 0
  fi

  if [ -n "$(git -C "$dir" status --porcelain 2>/dev/null)" ]; then
    warn "$name: $dir has uncommitted changes; left alone"
    SYNC_RESULT=refused
    return 0
  fi

  # Fetch only the one branch into its remote-tracking ref. This is the only
  # step that needs the network; offline, the checkout simply stays as it is.
  if ! git -C "$dir" fetch --quiet origin "+refs/heads/$FORK_BRANCH:refs/remotes/origin/$FORK_BRANCH"; then
    warn "$name: could not fetch origin in $dir; left at its current commit"
    SYNC_RESULT=failed
    return 0
  fi

  head="$(git -C "$dir" rev-parse HEAD)"
  remote="$(git -C "$dir" rev-parse "refs/remotes/origin/$FORK_BRANCH")"

  if [ "$head" = "$remote" ]; then
    say "$name: already at origin/$FORK_BRANCH ($(git -C "$dir" rev-parse --short HEAD))"
    SYNC_RESULT=unchanged
    return 0
  fi

  if git -C "$dir" merge-base --is-ancestor "$head" "$remote"; then
    if git -C "$dir" merge --quiet --ff-only "refs/remotes/origin/$FORK_BRANCH" >/dev/null; then
      say "$name: fast-forwarded to $(git -C "$dir" rev-parse --short HEAD)"
      SYNC_RESULT=updated
    else
      warn "$name: fast-forward of $dir failed; left at its current commit"
      SYNC_RESULT=failed
    fi
    return 0
  fi

  if git -C "$dir" merge-base --is-ancestor "$remote" "$head"; then
    warn "$name: $dir has local commits that are not on origin/$FORK_BRANCH; left alone"
  else
    warn "$name: $dir has diverged from origin/$FORK_BRANCH; left alone"
  fi
  SYNC_RESULT=refused
  return 0
}

file_hash() {
  if command -v sha256sum >/dev/null 2>&1; then
    sha256sum "$1" | cut -d' ' -f1
  else
    shasum -a 256 "$1" | cut -d' ' -f1
  fi
}

# build_no_mistakes <clone-dir> <gobin> <state-dir>
#
# `go install` would not do here: the fork's go.mod still declares upstream's
# module path, so the fork cannot be installed by path, only built from a
# clone. This is the Makefile's `build` target without make (Git for Windows
# ships none): the same -X settings, with these differences on purpose --
#
#   - Version is "main-<short sha>", which is not semver. no-mistakes treats a
#     version it cannot parse as a development build: no background update
#     check, and `no-mistakes update` declines instead of swapping in an
#     upstream release. The Makefile's `git describe` would give a bare sha,
#     and an all-digit sha does parse as a (huge) version.
#   - Date is the commit's, not the build's, so one commit is one binary.
#   - No telemetry host or site id: `go install` of upstream leaves them unset
#     as well, and the Makefile's defaults point at upstream's analytics.
#
# The generated files (skills/no-mistakes/SKILL.md, the Windows .syso
# resources) are committed, and the Makefile only checks them in `lint`, so
# no `go generate` or genskill step is needed to build.
build_no_mistakes() {
  local dir="$1" gobin="$2" state="$3"
  local commit short date exe out tmp stamp want have
  local -a goenv=()

  if ! command -v go >/dev/null 2>&1; then
    warn "go is not on PATH; no-mistakes was not built"
    return 0
  fi

  commit="$(git -C "$dir" rev-parse HEAD)"
  short="$(git -C "$dir" rev-parse --short=7 HEAD)"
  date="$(TZ=UTC git -C "$dir" log -1 --date=format-local:%Y-%m-%dT%H:%M:%SZ --format=%cd)"
  exe="$(go env GOEXE)"
  out="$gobin/no-mistakes$exe"
  stamp="$state/no-mistakes-built"

  # Rebuild when the commit changed, or when the installed binary is not the
  # one built from it: a personal-profile `go install` (or anything else)
  # overwriting it leaves a stamp that still names this commit.
  have=""
  [ -f "$stamp" ] && have="$(cat "$stamp")"
  if [ -f "$out" ]; then
    want="$commit $(file_hash "$out")"
    if [ "$have" = "$want" ]; then
      say "no-mistakes: $out is already built from $short"
      return 0
    fi
  fi

  mkdir -p "$gobin" "$state"
  tmp="$out.new"
  say "building no-mistakes main-$short -> $out"

  # Same environment as home.nix's installGoPackages needs: go shells out to
  # git, and cgo dependencies need a C compiler. Both are on PATH already by
  # the time this runs (the activation step and a Git Bash session both
  # arrange it).
  if command -v cygpath >/dev/null 2>&1; then
    # go.exe is a native Windows program. MSYS rewrites arguments that look
    # like paths, which the -X flags could trip on, and it rewrites nothing
    # in the environment, so hand over -o as a Windows path.
    goenv=(env MSYS_NO_PATHCONV=1)
    tmp="$(cygpath -w "$tmp")"
  fi

  if ! (
    cd "$dir"
    ${goenv[@]+"${goenv[@]}"} go build \
      -ldflags "-X $NO_MISTAKES_BUILDINFO.Version=main-$short -X $NO_MISTAKES_BUILDINFO.Commit=$short -X $NO_MISTAKES_BUILDINFO.Date=$date" \
      -o "$tmp" ./cmd/no-mistakes
  ); then
    rm -f "$out.new"
    warn "go build of no-mistakes failed; the installed binary is unchanged (if it needs cgo, install a C toolchain)"
    return 0
  fi

  # Replace in one rename so a failed or interrupted build never leaves a
  # half-written binary. On Windows a running no-mistakes.exe (the daemon) is
  # locked and the rename fails; that is reported, not fatal.
  if ! mv -f "$out.new" "$out"; then
    rm -f "$out.new"
    warn "could not replace $out (is the no-mistakes daemon running? run 'no-mistakes daemon stop', then re-run setup)"
    return 0
  fi

  printf '%s %s\n' "$commit" "$(file_hash "$out")" >"$stamp"
  say "no-mistakes: installed $("$out" --version 2>/dev/null | head -n1 || echo "main-$short")"
  say "no-mistakes: a running daemon keeps its old binary until 'no-mistakes daemon restart'"
}

main() {
  local firstmate_dir="${HOME}/developer/firstmate"
  local no_mistakes_dir="${HOME}/.local/share/devtools/no-mistakes"
  local gobin="${HOME}/go/bin"
  local state_dir="${HOME}/.local/state/devtools"

  while [ $# -gt 0 ]; do
    case "$1" in
    --firstmate-dir) firstmate_dir="${2:?--firstmate-dir needs a value}"; shift 2 ;;
    --no-mistakes-dir) no_mistakes_dir="${2:?--no-mistakes-dir needs a value}"; shift 2 ;;
    --gobin) gobin="${2:?--gobin needs a value}"; shift 2 ;;
    --state-dir) state_dir="${2:?--state-dir needs a value}"; shift 2 ;;
    -h | --help)
      sed -n '3,12p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'
      return 0
      ;;
    *)
      echo "Error: unknown argument '$1'." >&2
      return 2
      ;;
    esac
  done

  sync_checkout firstmate "$firstmate_dir" "$FIRSTMATE_URL"

  sync_checkout no-mistakes "$no_mistakes_dir" "$NO_MISTAKES_URL"
  case "$SYNC_RESULT" in
  cloned | updated | unchanged)
    build_no_mistakes "$no_mistakes_dir" "$gobin" "$state_dir"
    ;;
  *)
    say "no-mistakes: not rebuilt (its checkout was not synced to the fork's $FORK_BRANCH)"
    ;;
  esac

  [ "$WARNED" -eq 0 ] || return 3
}

if [ -z "${FORK_TOOLS_SOURCE_ONLY:-}" ]; then
  main "$@"
fi
