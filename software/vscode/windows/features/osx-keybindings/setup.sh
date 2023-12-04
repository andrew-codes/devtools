wingetInstall Microsoft.PowerToys
echo -e "Remember to map the left Windows key to Left Control in PowerToys Keyboard Manager. See https://learn.microsoft.com/en-us/windows/powertoys/keyboard-manager for more information."
echo "Backing up existing keybindings.json file to ~/AppData/Roaming/Code/User/keybindings.json.bak"
mv ~/AppData/Roaming/Code/User/keybindings.json ~/AppData/Roaming/Code/User/keybindings.json.bak
cp ./key-bindings.jsonc ~/AppData/Roaming/Code/User/keybindings.json
