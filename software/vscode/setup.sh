echo -e "
## VS Code
"

if [ "$DEVTOOLS_VSCODE" == "true" ]; then
  runInDir ./$os/setup.sh
else
  echo "Skipping"
fi
