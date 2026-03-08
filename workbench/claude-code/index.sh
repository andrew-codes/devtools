function install() {
  if ! command -v claude > /dev/null 2>&1; then
    npm install -g @anthropic-ai/claude-code
  fi
}

install
