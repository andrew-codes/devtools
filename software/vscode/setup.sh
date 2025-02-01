printH2 "VS Code"

if [ ! "$DEVTOOLS_VSCODE" == "true" ]; then
  echo -e "Skipping
"
  return 0
fi
cat ./README.md >../../.tmp/docs/bash.md

runInDir ./$os/setup.sh

echo -e ""

printH2 "VS Code"

if [ ! "$DEVTOOLS_VSCODE" == "true" ]; then
  echo -e "Skipping
"
  return 0
fi

doc="vscode.md"
cat ./README.md >../../.tmp/docs/$doc

if [ "$os" == 'osx' ]; then
  brewInstall visual-studio-code --cask
fi

if [ "$os" == 'windows' ]; then
  wingetInstall Microsoft.VisualStudioCode
  wingetInstall Microsoft.VisualStudioCode.CLI
fi

for featureDir in ./features/*/; do
  featureName=${featureDir%*/} # remove the trailing "/"
  featureName=${featureName##*/}
  featureToggle="DEVTOOLS_VSCODE_FEATURES_$(echo "$featureName" | tr a-z A-Z | sed s/-/_/g)"

  if [ ! "${!featureToggle}" == "true" ]; then
    continue
  fi

  echo "Enabling feature $featureName"
  if [ -f ./features/$featureName/setup.sh ]; then
    runInDir ./features/$featureName/setup.sh
  fi

  if [ -f ./features/$featureName/$os/setup.sh ]; then
    runInDir ./features/$featureName/$os/setup.sh
  fi

  # Aggregate docs
  cat ./features/$featureName/README.md >>../../.tmp/docs/$doc
  if [ -d ./features/$featureName/assets ]; then
    cp ./features/$featureName/assets/* ../../.tmp/docs/assets
  fi
done

echo -e ""
