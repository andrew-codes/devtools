BASHRC_PATH=~/.bashrc
if [ -f $BASHRC_PATH ]; then
  echo "Found a .bashrc file."
  echo "Removing any pre-exisitng sourcing of bash_profile"
  BASHRC_CONTENTS=$(cat "$BASHRC_PATH" | tr '\n' '\r' | sed -e "s;source \~/\.bash_profile;;g" | tr '\r' '\n')
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

echo "Modifying .bashrc to source bash_profile"
echo -e "$BASHRC_CONTENTS

source ~/.bash_profile
" >"$BASHRC_PATH"
