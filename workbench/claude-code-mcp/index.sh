function addMcpServer() {
  local name="$1"
  local config="$2"
  local claude_config="$HOME/.claude.json"

  if [ ! -f "$claude_config" ]; then
    echo '{}' >"$claude_config"
  fi

  local tmp
  tmp=$(mktemp)
  jq --arg name "$name" --argjson config "$config" '.mcpServers[$name] //= $config' "$claude_config" >"$tmp" && mv "$tmp" "$claude_config"
  echo "MCP server '$name' configured."
}

function install() {
  addMcpServer "context7" "$(
    cat <<EOF
{
  "type": "http",
  "url": "https://mcp.context7.com/mcp",
  "headers": {
    "CONTEXT7_API_KEY": "$CONTEXT7_API_KEY"
  }
}
EOF
  )"

  addMcpServer "sequential-thinking" '{
  "command": "npx",
  "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
}'

  addMcpServer "github" "$(
    cat <<EOF
{
  "type": "http",
  "url": "https://api.githubcopilot.com/mcp",
  "headers": {
    "Authorization": "Bearer $GITHUB_TOKEN"
  }
}
EOF
  )"

  addMcpServer "atlassian" '{
  "type": "http",
  "url": "https://mcp.atlassian.com/v1/mcp"
}'

  addMcpServer "serena" '{
  "type": "stdio",
  "command": "uvx",
  "args": [
    "--from",
    "git+https://github.com/oraios/serena",
    "serena",
    "start-mcp-server",
    "--context=claude-code",
    "--project-from-cwd"
  ],
  "env": {}
}'
}

install
