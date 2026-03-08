function installMac() {
  brew install --cask visual-studio-code
}

function _installWindows() {
  winget install --id Microsoft.VisualStudioCode --accept-package-agreements --accept-source-agreements

}

function installWindows() {
  runElevated _installWindows
  winget install --id Microsoft.VisualStudioCode.CLI --accept-package-agreements --accept-source-agreements
}

runIf isMac installMac
runIf isWindows installWindows

refreshEnv

extensions=$(sed -n '/"extensions"/,/\]/p' "$MANIFEST_FILE" | grep -o '"[^"]*"' | tr -d '"' | grep -v '^extensions$' | grep -v '^$')

while IFS= read -r extension; do
  code --install-extension "$extension" --force
done <<< "$extensions"
