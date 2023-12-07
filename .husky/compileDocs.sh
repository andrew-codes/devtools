function addToDocs() {
  touch features.md
  mkdir -p assets

  if [ -f ./software/$1/README.md ]; then
    cat ./software/$1/README.md >>./features.md
  else
    echo "# $(echo "$1" | sed 's/-/ /g' | sed -e 's/^./\U&/g; s/ ./\U&/g')" >>./features.md
  fi

  echo -e "" >>./features.md

  for featureDir in ./software/$1/features/*/; do
    featureName=${featureDir%*/} # remove the trailing "/"
    featureName=${featureName##*/}

    if [ -f "./software/$1/features/$featureName/README.md" ]; then
      cat ./software/$1/features/$featureName/README.md >>features.md

    fi
    if [ -d "./software/$1/features/$featureName/assets" ]; then
      cp ./software/$1/features/$featureName/assets/* assets
    fi

    echo -e "" >>./features.md

  done
}

# ---
rm -f features.md
rm -rf assets

for softwareDir in ./software/*/; do
  softwareName=${softwareDir%*/} # remove the trailing "/"
  softwareName=${softwareName##*/}

  if [ "$softwareName" == "settings" ]; then
    continue
  fi

  addToDocs $softwareName

done
