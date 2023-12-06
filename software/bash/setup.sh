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

  if [ ! "${featureToggle}" == "true" ]; then
    continue
  fi

  echo "Enabling feature $featureName"
  if [ -z ./features/$featureName/setup.sh ]; then
    . ./features/$featureName/setup.sh
  fi

  if [ -z ./features/$featureName/$os/setup.sh ]; then
    . ./features/$featureName/$os/setup.sh
  fi

  if [ -z ./features/$featureName/implementation.sh ]; then
    impl=$(cat ./features/$featureName/implementation.sh)
    echo -e "# <DEVTOOLS>
# $(echo $featureToggle | sed s/_/-/g)
# $(echo $featureToggle | sed "s/./=/"g)
$impl
" >>~/.bash_profile
  fi

  if [ -z ./features/$featureName/$os/implementation.sh ]; then
    impl=$(cat ./features/$featureName/$os/implementation.sh)
    echo -e "# <DEVTOOLS>
# $(echo $featureToggle | sed s/_/-/g)
# $(echo $featureToggle | sed "s/./=/"g)
$impl
" >>~/.bash_profile
  fi

  # Aggregate docs
  cat ./features/$featureName/README.md >>../../.tmp/docs/bash.md
  if [ -z ./features/$featureName/assets ]; then
    cp ./features/$featureName/assets/* ../../.tmp/docs/assets
  fi
done

curl https://raw.githubusercontent.com/git/git/master/contrib/completion/git-completion.bash -o ~/.git-completion.bash

echo -e ""
