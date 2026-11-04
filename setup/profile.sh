#!/usr/bin/env bash
#
# Resolve which profile this machine uses and print it on stdout.
#
#   setup/profile.sh [--profile personal|work]
#
# The machine's profile is recorded outside the repo, in
# ~/.config/devtools/profile (one word, no other content), so it never lands in
# a commit and survives re-cloning. The rules, in order:
#
#   1. --profile <name> wins, and is written to the record.
#   2. Otherwise the record is read.
#   3. Otherwise `personal`, the default that leaves a machine exactly as it
#      was before profiles existed. Nothing is written in that case.
#
# Anything other than `personal` or `work` -- from the flag or from a record
# somebody hand-edited -- is rejected with a message and a non-zero exit.
#
# setup.sh's platform scripts and rebuild.sh all call this, so there is one
# place that parses the flag and one place that knows the record's location.
# Keep the list of names in step with profiles.nix, which Nix evaluates.
# DEVTOOLS_PROFILE_FILE overrides the record's path (used to test this without
# touching a real machine's record).

set -euo pipefail

PROFILE_FILE="${DEVTOOLS_PROFILE_FILE:-$HOME/.config/devtools/profile}"
DEFAULT_PROFILE="personal"
VALID_PROFILES=(personal work)

usage() {
  echo "Usage: $(basename "$0") [--profile ${VALID_PROFILES[0]}|${VALID_PROFILES[1]}]" >&2
}

is_valid() {
  local name
  for name in "${VALID_PROFILES[@]}"; do
    [ "$1" = "$name" ] && return 0
  done
  return 1
}

requested=""
while [ $# -gt 0 ]; do
  case "$1" in
  --profile)
    if [ $# -lt 2 ]; then
      echo "Error: --profile needs a value (${VALID_PROFILES[*]})." >&2
      exit 1
    fi
    requested="$2"
    shift 2
    ;;
  --profile=*)
    requested="${1#--profile=}"
    shift
    ;;
  -h | --help)
    usage
    exit 0
    ;;
  *)
    echo "Error: unknown argument '$1'." >&2
    usage
    exit 1
    ;;
  esac
done

if [ -n "$requested" ]; then
  if ! is_valid "$requested"; then
    echo "Error: unknown profile '$requested'. Valid profiles: ${VALID_PROFILES[*]}." >&2
    exit 1
  fi
  mkdir -p "$(dirname "$PROFILE_FILE")"
  # Only rewrite when it changes, so a plain re-run leaves the file alone.
  if [ ! -f "$PROFILE_FILE" ] || [ "$(tr -d '[:space:]' <"$PROFILE_FILE")" != "$requested" ]; then
    echo "$requested" >"$PROFILE_FILE"
  fi
  echo "$requested"
  exit 0
fi

if [ -f "$PROFILE_FILE" ]; then
  recorded="$(tr -d '[:space:]' <"$PROFILE_FILE")"
  if ! is_valid "$recorded"; then
    echo "Error: $PROFILE_FILE says '$recorded', which is not a profile. Valid profiles: ${VALID_PROFILES[*]}." >&2
    echo "Fix the file, or pass --profile to overwrite it." >&2
    exit 1
  fi
  echo "$recorded"
  exit 0
fi

echo "$DEFAULT_PROFILE"
