# shellcheck shell=bash
# Windows only. Git for Windows' /etc/profile sources ~/.bash_profile for a
# login shell and stops there, and WezTerm starts bash as a login shell, so
# this is the entry point on that path.
#
# Nothing real lives here: keeping it all in ~/.bashrc means a non-login
# interactive shell -- `bash` inside a shell, an agent hook, a subshell an
# editor spawns -- gets exactly the same environment.

# shellcheck source=home/.bashrc
[ -f "$HOME/.bashrc" ] && . "$HOME/.bashrc"
