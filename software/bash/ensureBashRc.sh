BASHRC_PATH=~/.bashrc
if [ -f $BASHRC_PATH ]; then
  echo "Found a .bashrc file."
  echo "Removing any pre-existing sourcing of bash_profile"
  BASHRC_CONTENTS=$(cat "$BASHRC_PATH" | tr '\n' '\r' | sed -e "s;source \~/\.bash_profile;;g" | tr '\r' '\n')

  echo "Removing any pre-existing devtools installation"
  BASHRC_CONTENTS=$(echo "$BASHRC_CONTENTS" | tr '\n' '\r' | sed -e "s;# <DEVTOOLS>.*</DEVTOOLS>;;g" | tr '\r' '\n')
else
  echo "No .bashrc file found. Adding one."
  touch "$BASHRC_PATH"
  chmod +x "$BASHRC_PATH"
  BASHRC_CONTENTS=$(
    cat <<END
#!/usr/bin/env bash

END
  )
fi

echo "Rewriting .bashrc without devtooling"
echo "$BASHRC_CONTENTS" >"$BASHRC_PATH"
