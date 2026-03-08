#!/usr/bin/env bash

# Re-reads PATH from the Windows registry and updates the current shell session.
# Source this file after installing software so new commands are immediately available.

_reg_path=$(powershell.exe -NoProfile -Command \
  '[System.Environment]::GetEnvironmentVariable("PATH","Machine") + ";" + [System.Environment]::GetEnvironmentVariable("PATH","User")' \
  2>/dev/null | tr -d '\r')

if [ -n "$_reg_path" ]; then
  _unix_entries=""
  IFS=';' read -ra _reg_entries <<< "$_reg_path"
  for _entry in "${_reg_entries[@]}"; do
    [ -n "$_entry" ] || continue
    _unix=$(cygpath -u "$_entry" 2>/dev/null) && _unix_entries+=":$_unix"
  done
  [ -n "$_unix_entries" ] && export PATH="${_unix_entries#:}:$PATH"
fi

unset _reg_path _unix_entries _reg_entries _entry _unix
