printH2 "Bash"

if [ ! "$DEVTOOLS_BASH" == "true" ]; then
  echo -e "Skipping
"
  return 0
fi

cat ./README.md >../../.tmp/docs/bash.md

. ensureBashProfile.sh
. ensureBashrc.sh
. devToolsEnvVars.sh
. toolsBinPath.sh

for dir in ./features/*/; do
  dir=${dir%*/} # remove the trailing "/"
  dir=${dir##*/}
  featureToggle="DEVTOOLS_BASH_FEATURES_$(echo "$dir" | tr a-z A-Z | sed s/-/_/g)"

  if [ "${!featureToggle}" == "true" ]; then
    echo -e "Enabling feature $dir"
    impl=$(cat ./features/$dir/implementation.sh)
    echo -e "# <DEVTOOLS>
# $(echo $featureToggle | sed s/_/-/g)
# $(echo $featureToggle | sed "s/./=/"g)
$impl
" >>~/.bash_profile

    cat ./features/$dir/README.md >>../../.tmp/docs/bash.md
  fi
done

echo -e "
"
