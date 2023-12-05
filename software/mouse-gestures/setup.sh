printH2 "Mouse Guestures"

if [ ! "$DEVTOOLS_MOUSE_GESTURES" == "true" ]; then
  echo -e "Skipping
"
  return 0
fi

doc="mouse-gestures.md"
cat ./README.md >../../.tmp/docs/$doc

if [ "$os" == 'osx' ]; then
  brewInstall mac-mouse-fix --cask

  echo -e "Please see the devtools docs for more information: \"cat \$DEVTOOLS_BASH_DEV_HOME/docs/mouse-gestures.md\""
fi

echo -e ""
