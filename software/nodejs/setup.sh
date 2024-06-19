printH2 "Node.js"

if [ ! "$DEVTOOLS_NODEJS" == "true" ]; then
  echo -e "Skipping
"
  return 0
fi

cat ./README.md >../../.tmp/docs/nodejs.md

for featureDir in ./features/*/; do
  featureName=${featureDir%*/} # remove the trailing "/"
  featureName=${featureName##*/}
  featureToggle="DEVTOOLS_NODEJS_FEATURES_$(echo "$featureName" | tr a-z A-Z | sed s/-/_/g)"
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
" >>~/.bash_profile
  fi

  if [ -f ./features/$featureName/$os/implementation.sh ]; then
    impl=$(cat ./features/$featureName/$os/implementation.sh)
    echo -e "# <DEVTOOLS>
# $(echo $featureToggle | sed s/_/-/g)
# $(echo $featureToggle | sed "s/./=/"g)
$impl
# </DEVTOOLS>
" >>~/.bash_profile
  fi

  # Aggregate docs
  cat ./features/$featureName/README.md >>../../.tmp/docs/bash.md
  if [ -d ./features/$featureName/assets ]; then
    cp ./features/$featureName/assets/* ../../.tmp/docs/assets
  fi
done

echo -e ""
