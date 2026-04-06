#!/usr/bin/env bash
# Entry point for Ansible-based devtools setup.
# Assumes only bash is available; bootstraps Python and Ansible, then runs
# the appropriate playbook for the detected OS / CPU architecture.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Self-bootstrap: clone repo if not running from within it ──────────────────
# Supports: bash <(curl -fsSL https://raw.githubusercontent.com/.../setup.sh)
if [[ ! -f "$SCRIPT_DIR/ansible/site-macos-arm64.yml" ]]; then
  if [[ -z "${GITHUB_USERNAME:-}" ]]; then
    echo "Error: GITHUB_USERNAME must be set to clone the devtools repo." >&2
    exit 1
  fi

  _dev_home="${DEV_HOME:-$HOME/developer}"
  _repo_home="${REPO_HOME:-$_dev_home/repos}"
  _devtools_dir="${DEVTOOLS_HOME:-$_repo_home/devtools}"

  if [[ ! -d "$_devtools_dir" ]]; then
    echo "==> Cloning devtools repo into $_devtools_dir..."
    mkdir -p "$_repo_home"
    git clone "https://github.com/$GITHUB_USERNAME/devtools.git" "$_devtools_dir"
    chmod +x "$_devtools_dir/setup.sh"
  else
    echo "==> Devtools repo already exists at $_devtools_dir, skipping clone."
  fi

  echo "==> Re-running setup from cloned repo..."
  exec "$_devtools_dir/setup.sh"
fi

exec > >(tee "$SCRIPT_DIR/workbench.log") 2>&1

# ── Detect OS and architecture ────────────────────────────────────────────────
os_type=""
arch_type=""

if [[ "$OSTYPE" == darwin* ]]; then
  os_type="macos"
  case "$(uname -m)" in
    arm64)  arch_type="arm64" ;;
    x86_64) arch_type="amd64" ;;
    *)      arch_type="$(uname -m)" ;;
  esac
elif [[ "$OSTYPE" == msys* || "$OSTYPE" == cygwin* ]]; then
  os_type="windows"
  arch_type="amd64"
else
  echo "Error: Unsupported OS: $OSTYPE" >&2
  exit 1
fi

echo "==> Detected: $os_type / $arch_type"

# ── macOS bootstrap ───────────────────────────────────────────────────────────
if [[ "$os_type" == "macos" ]]; then
  echo "==> Ensuring Python 3 is available..."
  if ! command -v python3 &>/dev/null; then
    echo "Python 3 not found. Install Xcode Command Line Tools and re-run:"
    echo "  xcode-select --install"
    exit 1
  fi

  echo "==> Ensuring pip is up to date..."
  python3 -m ensurepip --upgrade 2>/dev/null || true
  python3 -m pip install --upgrade pip --quiet

  echo "==> Installing Ansible..."
  python3 -m pip install --upgrade ansible --quiet

  # Add user-local bin to PATH if ansible-playbook is not yet visible
  if ! command -v ansible-playbook &>/dev/null; then
    export PATH="$(python3 -m site --user-base)/bin:$PATH"
  fi

# ── Windows bootstrap ─────────────────────────────────────────────────────────
elif [[ "$os_type" == "windows" ]]; then
  # On Windows, App Execution Aliases create stub `python`/`python3` commands that
  # open the Microsoft Store instead of running Python. Validate the command actually
  # works (exit 0 + valid version) before trusting it.
  _python_works() { "$1" -c "import sys; sys.exit(0)" &>/dev/null 2>&1; }

  PYTHON_CMD=""
  if command -v python3 &>/dev/null && _python_works python3; then
    PYTHON_CMD="python3"
  elif command -v python &>/dev/null && _python_works python; then
    PYTHON_CMD="python"
  fi

  if [[ -z "$PYTHON_CMD" ]]; then
    echo "==> Python 3 not found. Installing via winget..."
    winget install --id Python.Python.3.12 \
      --accept-package-agreements --accept-source-agreements --silent
    APPDATA_WIN="$(cmd.exe /c echo %LOCALAPPDATA% 2>/dev/null | tr -d '\r')"
    APPDATA_UNIX="$(cygpath -u "$APPDATA_WIN" 2>/dev/null || echo "")"
    if [[ -n "$APPDATA_UNIX" ]]; then
      export PATH="$APPDATA_UNIX/Programs/Python/Python312:$APPDATA_UNIX/Programs/Python/Python312/Scripts:$PATH"
    fi
    if command -v python3 &>/dev/null && _python_works python3; then
      PYTHON_CMD="python3"
    elif command -v python &>/dev/null && _python_works python; then
      PYTHON_CMD="python"
    fi
  fi

  if [[ -z "$PYTHON_CMD" ]]; then
    echo "Error: Python not found after installation attempt." >&2
    exit 1
  fi

  echo "==> Ensuring pip is up to date..."
  $PYTHON_CMD -m ensurepip --upgrade 2>/dev/null || true
  $PYTHON_CMD -m pip install --upgrade pip --quiet

  echo "==> Installing Ansible and WinRM dependencies..."
  $PYTHON_CMD -m pip install --upgrade ansible pywinrm --quiet

  if ! command -v ansible-playbook &>/dev/null; then
    export PATH="$($PYTHON_CMD -m site --user-base)/bin:$PATH"
  fi

  echo "==> Installing Chocolatey..."
  if ! command -v choco &>/dev/null; then
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \
      "Set-ExecutionPolicy Bypass -Scope Process -Force; \
       [Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12; \
       iex ((New-Object Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))"
    export PATH="/c/ProgramData/chocolatey/bin:$PATH"
  fi

  echo "==> Configuring WinRM for local Ansible connections..."
  powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
    \$ErrorActionPreference = 'SilentlyContinue'
    Enable-PSRemoting -Force -SkipNetworkProfileCheck 2>\$null
    Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value \$true 2>\$null
    Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value \$true 2>\$null
    winrm quickconfig -quiet 2>\$null
  " || true
fi

# ── Validate Ansible is available ─────────────────────────────────────────────
if ! command -v ansible-playbook &>/dev/null; then
  echo "Error: ansible-playbook not found after installation." >&2
  exit 1
fi

echo "==> Installing Ansible collections..."
ansible-galaxy collection install -r "$SCRIPT_DIR/ansible/requirements.yml"

# ── Select inventory and playbook ─────────────────────────────────────────────
inventory=""
playbook=""

if [[ "$os_type" == "macos" ]]; then
  inventory="$SCRIPT_DIR/ansible/inventory-macos.yml"
  playbook="$SCRIPT_DIR/ansible/site-macos-arm64.yml"
elif [[ "$os_type" == "windows" ]]; then
  inventory="$SCRIPT_DIR/ansible/inventory-windows.yml"
  playbook="$SCRIPT_DIR/ansible/site-windows-amd64.yml"
fi

if [[ ! -f "$playbook" ]]; then
  echo "Error: Playbook not found: $playbook" >&2
  exit 1
fi

echo "==> Running playbook: $(basename "$playbook")..."
ansible-playbook \
  -i "$inventory" \
  "$playbook" \
  -e "devtools_repo_root=$SCRIPT_DIR"

echo ""
echo "Setup complete."
