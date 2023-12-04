printH2 "VS Code"

if [ ! "$DEVTOOLS_VSCODE" == "true" ]; then
  echo -e "Skipping
"
  return 0
fi
cat ./README.md >../../.tmp/docs/bash.md

runInDir ./$os/setup.sh

echo -e ""
