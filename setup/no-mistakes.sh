#!/usr/bin/env bash
#
# Installs the no-mistakes release binary from andrew-codes' fork.
#
#   setup/no-mistakes.sh --version X.Y.Z [--bindir DIR]
#
# Every profile on both platforms uses this; upstream (kunchenguid) is not an
# install source. It downloads the release archive for this OS and arch from
# https://github.com/andrew-codes/no-mistakes/releases, checks it against the
# release's checksums.txt, and replaces DIR/no-mistakes (default ~/go/bin, which
# is already on PATH) in one rename. A binary that already reports the wanted
# version is left alone, so re-running is cheap.
#
# macOS: the fork's arm64 binary is ad-hoc signed and its amd64 one is
# unsigned. curl sets no quarantine flag, so Gatekeeper is not involved; an
# arm64 binary that fails `codesign --verify` is re-signed ad hoc, which is all
# Apple Silicon requires.
#
# Exit status: 0 on success or already current, 1 when it could not install
# (a message has been printed; callers turn that into a warning), 2 for usage.

set -euo pipefail

REPO="andrew-codes/no-mistakes"

version=""
bindir="${HOME}/go/bin"
while [ $# -gt 0 ]; do
  case "$1" in
  --version) version="${2:?--version needs a value}"; shift 2 ;;
  --bindir) bindir="${2:?--bindir needs a value}"; shift 2 ;;
  -h | --help) sed -n '3,19p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
  *) echo "Error: unknown argument '$1'." >&2; exit 2 ;;
  esac
done
[ -n "$version" ] || { echo "Error: --version is required." >&2; exit 2; }
version="${version#v}"
tag="v$version"

say() { echo "    $*"; }
fail() { echo "    WARNING: no-mistakes: $*" >&2; exit 1; }

case "$(uname -s)" in
Darwin) os=darwin; ext=tar.gz; exe=no-mistakes ;;
Linux) os=linux; ext=tar.gz; exe=no-mistakes ;;
MINGW* | MSYS* | CYGWIN*) os=windows; ext=zip; exe=no-mistakes.exe ;;
*) fail "unsupported OS $(uname -s)" ;;
esac
case "$(uname -m)" in
x86_64 | amd64) arch=amd64 ;;
arm64 | aarch64) arch=arm64 ;;
*) fail "unsupported architecture $(uname -m)" ;;
esac

out="$bindir/$exe"
if [ -x "$out" ] && "$out" --version 2>/dev/null | head -n1 | grep -qF "version $tag "; then
  say "no-mistakes $tag (installed)"
  exit 0
fi

archive="no-mistakes-$tag-$os-$arch.$ext"
base="https://github.com/$REPO/releases/download/$tag"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT

say "no-mistakes $tag: downloading $archive"
curl -fsSL --retry 2 -o "$tmp/$archive" "$base/$archive" || fail "could not download $base/$archive"
curl -fsSL --retry 2 -o "$tmp/checksums.txt" "$base/checksums.txt" || fail "could not download $base/checksums.txt"

want="$(awk -v f="$archive" '$2 == f { print $1 }' "$tmp/checksums.txt")"
[ -n "$want" ] || fail "checksums.txt has no entry for $archive"
if command -v sha256sum >/dev/null 2>&1; then
  have="$(sha256sum "$tmp/$archive" | cut -d' ' -f1)"
else
  have="$(shasum -a 256 "$tmp/$archive" | cut -d' ' -f1)"
fi
[ "$have" = "$want" ] || fail "checksum mismatch for $archive (expected $want, got $have); not installed"

if [ "$ext" = zip ]; then
  # Git for Windows ships no unzip; Windows PowerShell always has Expand-Archive.
  powershell.exe -NoProfile -Command \
    "Expand-Archive -LiteralPath '$(cygpath -w "$tmp/$archive")' -DestinationPath '$(cygpath -w "$tmp/x")' -Force" ||
    fail "could not extract $archive"
else
  mkdir "$tmp/x"
  tar -xzf "$tmp/$archive" -C "$tmp/x" || fail "could not extract $archive"
fi
[ -f "$tmp/x/$exe" ] || fail "$archive does not contain $exe"
chmod +x "$tmp/x/$exe"

if [ "$os" = darwin ]; then
  xattr -d com.apple.quarantine "$tmp/x/$exe" 2>/dev/null || true
  if [ "$arch" = arm64 ] && ! codesign --verify "$tmp/x/$exe" >/dev/null 2>&1; then
    codesign --force --sign - "$tmp/x/$exe" >/dev/null 2>&1 || fail "could not ad-hoc sign the arm64 binary"
  fi
fi

"$tmp/x/$exe" --version 2>/dev/null | head -n1 | grep -qF "version $tag " ||
  fail "the downloaded binary does not report $tag; not installed"

mkdir -p "$bindir"
# Replace in one rename so an interrupted run never leaves a half-written
# binary. On Windows a running no-mistakes.exe (the daemon) is locked and the
# move fails; that is reported, not fatal.
cp "$tmp/x/$exe" "$out.new"
mv -f "$out.new" "$out" || { rm -f "$out.new"; fail "could not replace $out (is the daemon running? run 'no-mistakes daemon stop', then re-run setup)"; }

say "no-mistakes: installed $("$out" --version 2>/dev/null | head -n1)"
say "no-mistakes: a running daemon keeps its old binary until 'no-mistakes daemon restart'"
