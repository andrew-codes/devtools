printH2 "VS Code"

if [ "$DEVTOOLS_VSCODE" == "true" ]; then
  runInDir ./$os/setup.sh
else
  echo -e "Skipping"
fi
