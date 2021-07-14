#!/usr/bin/env bash

PROFILE_FILE_PATH=~/.bash_profile

if [ -f $PROFILE_FILE_PATH ]; then
    echo "Found a .bash_profile file."
    echo "Removing any pre-exisitng devtools installation"
    BASH_PROFILE_CONTENTS=$(cat "$PROFILE_FILE_PATH" | tr '\n' '\r' | sed -e "s;# <DEVTOOLS>.*</DEVTOOLS>;;g" | tr '\r' '\n')
    echo "$BASH_PROFILE_CONTENTS"
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

echo "Modifying .bash_profile with devtools"
echo "$BASH_PROFILE_CONTENTS" >"$PROFILE_FILE_PATH"
echo -e "\n" >>"$PROFILE_FILE_PATH"
cat ${DEVTOOLS_HOME}/bash_features.sh >>"$PROFILE_FILE_PATH"
echo -e "\n" >>"$PROFILE_FILE_PATH"
echo -e "$(
    cat <<END
# <DEVTOOLS>
source ${DEVTOOLS_HOME}/bash/index.sh
# </DEVTOOLS>
END
)" >>"$PROFILE_FILE_PATH"

BASHRC_PATH=~/.bashrc
if [ -f $BASHRC_PATH ]; then
    echo "Found a .bashrc file."
    echo "Removing any pre-exisitng sourcing of bash_profile"
    BASHRC_CONTENTS=$(cat "$BASHRC_PATH" | tr '\n' '\r' | sed -e "s;source \.bash_profile;;g" | tr '\r' '\n')
    echo "$BASHRC_CONTENTS"
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
echo "$BASHRC_CONTENTS" >"$BASHRC_PATH"
echo -e "\n" >>"$BASHRC_PATH"
echo -e "\n" >>"$BASHRC_PATH"
echo -e "$(
    cat <<END
source ~/.bash_profile
END
)" >>"$PROFILE_FILE_PATH"
