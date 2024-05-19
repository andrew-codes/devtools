printH1 "Setup Overview"
echo -e "Detected OS: $os
"
printH2 "Settings"
echo -e "$(printenv | grep '^DEVTOOLS_')
"
printH1 "Configured Software"
