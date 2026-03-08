function installMac() {
  brew install --cask visual-studio-code
}

function installWindows() {
  winget install --id Microsoft.VisualStudioCode
  winget install --id Microsoft.VisualStudioCode.CLI
}

runIf isMac installMac
runIf isWindows installWindows

refreshEnv

extensions=$(sed -n '/"extensions"/,/\]/p' "$MANIFEST_FILE" | grep -o '"[^"]*"' | tr -d '"' | grep -v '^extensions$' | grep -v '^$')

while IFS= read -r extension; do
  code --install-extension "$extension" --force
done <<< "$extensions"
