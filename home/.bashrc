# shellcheck shell=bash
# Windows only. The peer of `programs.zsh` in home.nix.
#
# HO-243 makes bash the shell on Windows -- it is what Git for Windows ships
# and what WezTerm launches there -- so this file carries what home.nix's zsh
# block carries on macOS: PATH, session variables, the prompt, completions for
# the custom commands, secret loading and the aliases.
#
# Symlinked to ~/.bashrc by setup/windows.sh, so edits here take effect in the
# next shell with no rebuild.
#
# Where a zsh feature has no bash equivalent, setup/windows-parity.md records
# the decision rather than leaving a silent gap.

# ---------------------------------------------------------------------------
# PATH
#
# Re-added idempotently rather than appended once: a shell that inherits a PATH
# from a long-lived parent (a herdr pane, an agent harness) must still resolve
# the custom commands. Same reasoning as home.nix's initContent loop.
# ---------------------------------------------------------------------------
for _dir in "$HOME/go/bin" "${VOLTA_HOME:-$HOME/.volta}/bin" "$HOME/.local/bin"; do
  case ":$PATH:" in
  *":$_dir:"*) ;;
  *) PATH="$_dir:$PATH" ;;
  esac
done
unset _dir
export PATH

# ---------------------------------------------------------------------------
# Session variables (home.nix's home.sessionVariables)
#
# No SSH_AUTH_SOCK here on purpose. On macOS it points at 1Password's agent
# socket; on Windows 1Password serves the OpenSSH agent named pipe instead,
# which Git for Windows' own ssh cannot speak. .gitconfig-windows routes git
# through the native ssh.exe, which finds that pipe with no variable set.
# ---------------------------------------------------------------------------
export EDITOR="nvim"
export REPO_HOME="$HOME/developer/repos"
export VOLTA_HOME="${VOLTA_HOME:-$HOME/.volta}"

# Everything in this environment hooks agents through bash scripts, and Claude
# Code on Windows will not run one until it is told where bash lives.
# setup/windows.sh sets this in the Windows user environment, so this is only
# the fallback for a shell started before setup ran. Probed rather than
# hard-coded: a per-user Git install lives somewhere else entirely.
if [ -z "${CLAUDE_CODE_GIT_BASH_PATH:-}" ]; then
  for _root in "${ProgramW6432:-}" "${ProgramFiles:-}" "${LOCALAPPDATA:-}\\Programs"; do
    [ -n "$_root" ] || continue
    if [ -f "$(cygpath -u "$_root" 2>/dev/null)/Git/bin/bash.exe" ]; then
      export CLAUDE_CODE_GIT_BASH_PATH="$_root\\Git\\bin\\bash.exe"
      break
    fi
  done
  unset _root
fi

# Everything below is for interactive shells only.
case $- in
*i*) ;;
*) return ;;
esac

# ---------------------------------------------------------------------------
# Prompt
# ---------------------------------------------------------------------------
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init bash)"
fi

# ---------------------------------------------------------------------------
# History and line editing
#
# The closest bash gets to zsh-autosuggestions without pulling in ble.sh: Up
# and Down search history for what has already been typed instead of walking it
# blindly. Ctrl-F stays readline's forward-char, which is the same keystroke
# that accepts a suggestion on macOS.
# ---------------------------------------------------------------------------
HISTSIZE=10000
HISTFILESIZE=20000
HISTCONTROL=ignoreboth
shopt -s histappend
shopt -s checkwinsize

bind '"\e[A": history-search-backward'
bind '"\e[B": history-search-forward'

# oh-my-zsh's colored-man-pages plugin, done with what less already supports.
export LESS_TERMCAP_md=$'\e[1;36m'  # bold -> cyan
export LESS_TERMCAP_me=$'\e[0m'
export LESS_TERMCAP_us=$'\e[1;32m'  # underline -> green
export LESS_TERMCAP_ue=$'\e[0m'
export LESS_TERMCAP_so=$'\e[1;33;44m' # search match
export LESS_TERMCAP_se=$'\e[0m'

# ---------------------------------------------------------------------------
# Completions
#
# The same bash `complete -F` scripts macOS loads into zsh through bashcompinit;
# here they just source. setup/windows.sh links the repo directory to
# ~/.config/bash/bin-completion.
# ---------------------------------------------------------------------------
if [ -d "$HOME/.config/bash/bin-completion" ]; then
  for _completion in "$HOME/.config/bash/bin-completion"/*; do
    # shellcheck disable=SC1090  # one file per custom command, resolved at runtime
    [ -f "$_completion" ] && . "$_completion"
  done
  unset _completion
fi

# ---------------------------------------------------------------------------
# Secrets
#
# ~/.env is untracked; setup/windows.sh stubs every required key into it.
# `set -a` exports what it defines, so child processes -- agents, MCP servers --
# inherit them.
# ---------------------------------------------------------------------------
if [ -f "$HOME/.env" ]; then
  set -a
  # shellcheck disable=SC1091  # untracked, machine-local
  . "$HOME/.env"
  set +a
fi

# Say so, every shell, until each stubbed secret actually has a value. The keys
# are read out of ~/.env rather than listed here, so the required-secret list
# stays declared in the two places that actually stub it: secretEnvVars in
# home.nix and SECRET_ENV_VARS in setup/windows.sh. The file was just sourced
# under `set -a`, so the environment is what says whether a key has a value --
# which also honours one exported from somewhere else.
if [ -f "$HOME/.env" ]; then
  _missing_secrets=""
  while IFS= read -r _line; do
    case "$_line" in
    '' | '#'*) continue ;;
    esac
    _var="${_line%%=*}"
    # Not a `KEY=` line at all, or not a usable variable name.
    [ "$_var" != "$_line" ] || continue
    case "$_var" in
    *[!A-Za-z0-9_]*) continue ;;
    esac
    if [ -z "${!_var:-}" ]; then
      _missing_secrets="${_missing_secrets:+$_missing_secrets, }$_var"
    fi
  done <"$HOME/.env"
  if [ -n "$_missing_secrets" ]; then
    echo "⚠  Unset secrets in ~/.env: $_missing_secrets" >&2
    echo "   Set them there before using tooling that needs them." >&2
  fi
  unset _missing_secrets _line _var
fi

# ---------------------------------------------------------------------------
# Aliases (home.nix's shellAliases)
# ---------------------------------------------------------------------------
alias ..="cd .."
alias add="git add ."
alias m="git switch main"
alias cc="claude --dangerously-skip-permissions"
alias co="codex --full-auto"
