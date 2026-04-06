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

running_in_wsl=false
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
elif grep -qi microsoft /proc/version 2>/dev/null; then
  # Running inside WSL — act as the Windows control node.
  os_type="windows"
  arch_type="amd64"
  running_in_wsl=true
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
# Ansible does not support Windows as a control node (os.get_blocking is
# unavailable on Windows). WSL is used as the control node; it connects back
# to Windows via WinRM.
elif [[ "$os_type" == "windows" ]]; then
  if [[ "$running_in_wsl" == true ]]; then
    # ── Already inside WSL (e.g. re-running after restart when Git Bash broke) ──
    echo "==> Running inside WSL."

    echo "==> Installing Ansible and WinRM dependencies..."
    pip3 install --quiet --upgrade ansible pywinrm 2>/dev/null \
      || pip install --quiet --upgrade ansible pywinrm

    echo "==> Configuring WinRM for Ansible connections (requires elevation)..."
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
      Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command',
        'Enable-PSRemoting -Force -SkipNetworkProfileCheck; Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value \$true; Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value \$true; winrm quickconfig -quiet'
      )
    "

    WSL_SCRIPT_DIR="$SCRIPT_DIR"

  else
    # ── Running from Git Bash / msys / cygwin ────────────────────────────────
    echo "==> Checking WSL availability..."
    if ! wsl -- echo ok &>/dev/null 2>&1; then
      echo "==> WSL not found or no distro installed. Installing WSL (requires elevation)..."
      powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
        Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList @(
          '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', 'wsl --install'
        )
      "
      echo ""
      echo "WSL installation complete. Please restart your computer, then re-run setup"
      echo "by opening the Ubuntu app (or any WSL terminal) and running:"
      echo "  bash $(cygpath -w "$SCRIPT_DIR")/setup.sh"
      echo ""
      echo "Note: Git Bash may not work after restart. Use the WSL/Ubuntu terminal instead."
      exit 0
    fi

    echo "==> Installing Ansible and WinRM dependencies inside WSL..."
    wsl -- bash -c "pip3 install --quiet --upgrade ansible pywinrm 2>/dev/null \
      || pip install --quiet --upgrade ansible pywinrm"

    echo "==> Configuring WinRM for Ansible connections (requires elevation)..."
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
      Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command',
        'Enable-PSRemoting -Force -SkipNetworkProfileCheck; Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value \$true; Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value \$true; winrm quickconfig -quiet'
      )
    "

    # Translate the Windows repo path to a WSL path for use in ansible commands.
    WSL_SCRIPT_DIR="$(wsl wslpath -u "$(cygpath -w "$SCRIPT_DIR")")"
  fi
fi

# ── Validate Ansible is available ─────────────────────────────────────────────
if [[ "$os_type" == "windows" ]]; then
  if ! wsl -- command -v ansible-playbook &>/dev/null; then
    echo "Error: ansible-playbook not found in WSL after installation." >&2
    exit 1
  fi
elif ! command -v ansible-playbook &>/dev/null; then
  echo "Error: ansible-playbook not found after installation." >&2
  exit 1
fi

# ── Select inventory and playbook ─────────────────────────────────────────────
inventory=""
playbook=""

if [[ "$os_type" == "macos" ]]; then
  inventory="$SCRIPT_DIR/ansible/inventory-macos.yml"
  playbook="$SCRIPT_DIR/ansible/site-macos-arm64.yml"
elif [[ "$os_type" == "windows" ]]; then
  inventory="$WSL_SCRIPT_DIR/ansible/inventory-windows.yml"
  playbook="$WSL_SCRIPT_DIR/ansible/site-windows-amd64.yml"
fi

if [[ "$os_type" != "windows" && ! -f "$playbook" ]]; then
  echo "Error: Playbook not found: $playbook" >&2
  exit 1
fi

echo "==> Installing Ansible collections..."
if [[ "$os_type" == "windows" && "$running_in_wsl" == false ]]; then
  wsl -- ansible-galaxy collection install -r "$WSL_SCRIPT_DIR/ansible/requirements.yml"
else
  ansible-galaxy collection install -r "$SCRIPT_DIR/ansible/requirements.yml"
fi

echo "==> Running playbook: $(basename "$playbook")..."
if [[ "$os_type" == "windows" && "$running_in_wsl" == false ]]; then
  wsl -- ansible-playbook \
    -i "$inventory" \
    "$playbook" \
    -e "devtools_repo_root=$WSL_SCRIPT_DIR"
else
  ansible-playbook \
    -i "$inventory" \
    "$playbook" \
    -e "devtools_repo_root=$SCRIPT_DIR"
fi

echo ""
echo "Setup complete."
