wingetInstall Microsoft.VisualStudioCode

cat ./README.md >../../.tmp/docs/vscode.md
for dir in ./features/*/; do
  dir=${dir%*/} # remove the trailing "/"
  dir=${dir##*/}
  featureToggle="DEVTOOLS_VSCODE_FEATURES_$(echo "$dir" | tr a-z A-Z | sed s/-/_/g)"

  if [ "${!featureToggle}" == "true" ]; then
    runInDir ./features/$dir/setup.sh

    cat ./features/$dir/README.md >>../../.tmp/docs/vscode.md
  fi
done
