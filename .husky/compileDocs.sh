touch ./features.md
mkdir -p assets

function addToDocs() {
  if [ -f ./software/$1/README.md ]; then
    cat ./software/$1/README.md >>./features.md
  else
    echo -e "# $(echo "$1" | sed s/-/ /g)" >>./features.md
  fi
}

for softwareDir in ./software/*/; do
  softwareName=${softwareDir%*/} # remove the trailing "/"
  softwareName=${softwareName##*/}

  softwareReadme=$(echo -e "# $softwareName
")
  if [ -f ./software/$softwareName/README.md ]; then
    softwareReadme=$(cat ./software/$softwareName/README.md)
  fi

  echo -e "$softwareReadme" >>./features.md
done
