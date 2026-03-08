function isMac() {
  [[ $OSTYPE == darwin* ]]
}

function isWindows() {
  [[ $OSTYPE == msys* ]]
}

function isLinux() {
  [[ $OSTYPE == linux* ]]
}

function isArm() {
  [[ "$(uname -m)" == arm64 ]]
}

function isIntel() {
  [[ "$(uname -m)" == x86_64 ]]
}

function runIf() {
  local args=("$@")
  local action="${args[-1]}"
  local expr_args=("${args[@]:0:${#args[@]}-1}")

  local condition=""
  local token
  for token in "${expr_args[@]}"; do
    case "$token" in
    and) condition+=" &&" ;;
    or) condition+=" ||" ;;
    not) condition+=" !" ;;
    *) condition+=" $token" ;;
    esac
  done

  if eval "$condition"; then
    "$action"
  fi
}

function addToBashrc() {
  local id="$1"
  local fn_or_block="$2"

  local block
  if declare -f "$fn_or_block" > /dev/null 2>&1; then
    block=$(declare -f "$fn_or_block" | tail -n +3 | sed '$d')
  else
    block="$fn_or_block"
  fi

  touch ~/.bashrc

  # Remove existing block with this ID
  local tmpfile
  tmpfile=$(mktemp)
  sed "/# BEGIN devtools:${id}/,/# END devtools:${id}/d" ~/.bashrc > "$tmpfile"
  mv "$tmpfile" ~/.bashrc

  # Append new block wrapped in ID markers
  printf '\n# BEGIN devtools:%s\n%s\n# END devtools:%s\n' "$id" "$block" "$id" >> ~/.bashrc
}

function installBinFiles() {
  mkdir -p "$TOOLS_BIN_HOME"

  local os_name=""
  if isMac; then
    os_name="osx"
  elif isWindows; then
    os_name="windows"
  elif isLinux; then
    os_name="linux"
  fi

  # General bin first, then OS-specific — OS-specific overwrites on name collision
  local bin_dirs=("./bin")
  [ -n "$os_name" ] && bin_dirs+=("./bin/$os_name")

  local bin_dir bin_file cmd_name completion_file
  for bin_dir in "${bin_dirs[@]}"; do
    [ -d "$bin_dir" ] || continue
    for bin_file in "$bin_dir"/*; do
      [ -f "$bin_file" ] || continue
      cmd_name=$(basename "$bin_file")

      cp "$bin_file" "$TOOLS_BIN_HOME/$cmd_name"
      chmod +x "$TOOLS_BIN_HOME/$cmd_name"
      echo "Installed: $cmd_name"

      completion_file="./completion/$cmd_name"
      if [ -f "$completion_file" ]; then
        addToBashrc "completion-${cmd_name}" "$(cat "$completion_file")"
      fi
    done
  done
}
