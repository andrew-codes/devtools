wingetInstall Microsoft.VisualStudioCode
wingetInstall Microsoft.PowerToys

echo -e "Remember to map the left Windows key to Left Control in PowerToys Keyboard Manager. See https://learn.microsoft.com/en-us/windows/powertoys/keyboard-manager for more information."

cp ./key-bindings.jsonc ~/AppData/Roaming/Code/User/keybindings.json
