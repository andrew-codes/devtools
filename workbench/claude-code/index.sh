function ccBashrcContentsWindows() {
  export CLAUDE_CODE_GIT_BASH_PATH="C:\Program Files\Git\bin\bash.exe"
}

function addCcBashRcWindows() {
  addToBashrc "claude-code" ccBashrcContentsWindows
}

function install() {
  if ! command -v claude >/dev/null 2>&1; then
    npm install -g @anthropic-ai/claude-code
  fi
}

install
runIf isWindows addCcBashRcWindows
