function installMac() {
    if ! command -v uvx &> /dev/null; then
        brew install uv
    fi
}

function installWindows() {
    if ! command -v uvx &> /dev/null; then
        winget install --id astral-sh.uv --accept-package-agreements --accept-source-agreements
    fi
}

runIf isMac installMac
runIf isWindows installWindows