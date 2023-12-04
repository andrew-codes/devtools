PROFILE_FILE_PATH=~/.bash_profile

if [ -f $PROFILE_FILE_PATH ]; then
  echo "Found a .bash_profile file."
  echo "Removing any pre-exisitng devtools installation"
  BASH_PROFILE_CONTENTS=$(cat "$PROFILE_FILE_PATH" | tr '\n' '\r' | sed -e "s;# <DEVTOOLS>.*</DEVTOOLS>;;g" | tr '\r' '\n')
else
  echo "No .bash_profile file found. Adding one."
  touch "$PROFILE_FILE_PATH"
  chmod +x "$PROFILE_FILE_PATH"
  BASH_PROFILE_CONTENTS=$(
    cat <<END
#!/usr/bin/env bash

END
  )
fi
echo "$BASH_PROFILE_CONTENTS" >"$PROFILE_FILE_PATH"
