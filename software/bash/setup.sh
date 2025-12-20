printH2 "Bash"

if [ ! "$DEVTOOLS_BASH" == "true" ]; then
  echo -e "Skipping
"
  return 0
fi

cat ./README.md >../../.tmp/docs/bash.md

. ensureBashProfile.sh
. ensureBashRc.sh
. devToolsEnvVars.sh
. toolsBinPath.sh

for featureDir in ./features/*/; do
  featureName=${featureDir%*/} # remove the trailing "/"
  featureName=${featureName##*/}
  featureToggle="DEVTOOLS_BASH_FEATURES_$(echo "$featureName" | tr a-z A-Z | sed s/-/_/g)"
  if [ ! "${!featureToggle}" == "true" ]; then
    echo "Skipping feature $featureName due to $featureToggle not being set to true."
    continue
  fi

  echo "Enabling feature $featureName"
  if [ -f ./features/$featureName/setup.sh ]; then
    . ./features/$featureName/setup.sh
  fi

  if [ -f ./features/$featureName/$os/setup.sh ]; then
    . ./features/$featureName/$os/setup.sh
  fi

  if [ -f ./features/$featureName/implementation.sh ]; then
    impl=$(cat ./features/$featureName/implementation.sh)
    echo -e "# <DEVTOOLS>
# $(echo $featureToggle | sed s/_/-/g)
# $(echo $featureToggle | sed "s/./=/"g)
$impl
# </DEVTOOLS>
" >>~/.bashrc
  fi

  if [ -f ./features/$featureName/$os/implementation.sh ]; then
    impl=$(cat ./features/$featureName/$os/implementation.sh)
    echo -e "# <DEVTOOLS>
# $(echo $featureToggle | sed s/_/-/g)
# $(echo $featureToggle | sed "s/./=/"g)
$impl
# </DEVTOOLS>
" >>~/.bashrc
  fi

  # Copy bin files if they exist (from feature root bin directory)
  if [ -d ./features/$featureName/bin ] && [ -n "$(ls -A ./features/$featureName/bin 2>/dev/null)" ]; then
    echo "Copying bin files from $featureName to $DEVTOOLS_BASH_TOOLS_BIN_HOME"
    cp ./features/$featureName/bin/* "$DEVTOOLS_BASH_TOOLS_BIN_HOME/"
  fi

  # Copy OS-specific bin files if they exist
  if [ -d ./features/$featureName/$os/bin ] && [ -n "$(ls -A ./features/$featureName/$os/bin 2>/dev/null)" ]; then
    echo "Copying OS-specific bin files from $featureName/$os to $DEVTOOLS_BASH_TOOLS_BIN_HOME"
    cp ./features/$featureName/$os/bin/* "$DEVTOOLS_BASH_TOOLS_BIN_HOME/"
  fi

  # Aggregate docs
  cat ./features/$featureName/README.md >>../../.tmp/docs/bash.md
  if [ -d ./features/$featureName/assets ]; then
    cp ./features/$featureName/assets/* ../../.tmp/docs/assets
  fi
done

echo -e ""
