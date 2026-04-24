#!/usr/bin/env bash
# Entry point for Ansible-based devtools setup.
# Assumes only bash is available; bootstraps Python and Ansible, then runs
# the appropriate playbook for the detected OS / CPU architecture.

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# ── Self-bootstrap: clone repo if not running from within it ──────────────────
# Supports: bash $(curl -fsSL https://raw.githubusercontent.com/.../setup.sh)
if [[ ! -f "$SCRIPT_DIR/ansible/site-macos-arm64.yml" ]]; then
  if [[ -z ${GITHUB_USERNAME:-} ]]; then
    echo "Error: GITHUB_USERNAME must be set to clone the devtools repo." >&2
    exit 1
  fi

  _dev_home="${DEV_HOME:-$HOME/developer}"
  _repo_home="${REPO_HOME:-$_dev_home/repos}"
  _devtools_dir="${DEVTOOLS_HOME:-$_repo_home/devtools}"

  if [[ ! -d $_devtools_dir ]]; then
    echo "==> Cloning devtools repo into $_devtools_dir..."
    mkdir -p "$_repo_home"
    git clone "https://github.com/$GITHUB_USERNAME/devtools.git" "$_devtools_dir"
    chmod +x "$_devtools_dir/setup.sh"
  else
    echo "==> Devtools repo already exists at $_devtools_dir, updating..."
    git -C "$_devtools_dir" fetch origin
    git -C "$_devtools_dir" reset --hard origin/main
  fi

  echo "==> Re-running setup from cloned repo..."
  exec "$_devtools_dir/setup.sh"
fi

exec > >(tee "$SCRIPT_DIR/workbench.log") 2>&1

# ── Self-update: pull latest main when running directly from the repo ─────────
if [[ -z ${DEVTOOLS_UPDATED:-} ]] && git -C "$SCRIPT_DIR" remote get-url origin &>/dev/null 2>&1; then
  echo "==> Updating devtools repo to latest main..."
  git -C "$SCRIPT_DIR" fetch origin
  git -C "$SCRIPT_DIR" reset --hard origin/main
  echo "==> Re-running setup after update..."
  export DEVTOOLS_UPDATED=1
  exec "$SCRIPT_DIR/setup.sh"
fi

ensure_windows_bootstrap() {
  local bootstrap_ps1="${SCRIPT_DIR}/.devtools-windows-bootstrap.ps1"
  local bootstrap_ps1_windows=""
  local bootstrap_log="${SCRIPT_DIR}/.devtools-windows-bootstrap.log"
  local bootstrap_log_windows=""

  cat > "$bootstrap_ps1" << 'EOF'
param(
  [string]$LogPath = 'C:\Users\Public\devtools-windows-bootstrap.log'
)

function Write-Log {
  param([string]$Message)
  $line = "[$(Get-Date -Format 'yyyy-MM-dd HH:mm:ss')] $Message"
  Add-Content -Path $LogPath -Value $line
}

$ErrorActionPreference = 'Stop'
New-Item -ItemType File -Path $LogPath -Force | Out-Null
Write-Log 'Bootstrap start'

try {
Set-Service WinRM -StartupType Automatic
Start-Service WinRM
Enable-PSRemoting -Force -SkipNetworkProfileCheck
Set-Item -Path WSMan:\localhost\Service\Auth\Basic -Value $true
Set-Item -Path WSMan:\localhost\Service\AllowUnencrypted -Value $true
Write-Log 'WinRM configured'

try {
  New-NetFirewallRule -DisplayName WinRM-Ansible -Direction Inbound -Protocol TCP -LocalPort 5985 -Action Allow -Profile Any -ErrorAction Stop | Out-Null
} catch {
  Set-NetFirewallRule -DisplayName WinRM-Ansible -Action Allow -Profile Any | Out-Null
}
Write-Log 'Firewall rule configured'

winrm quickconfig -quiet | Out-Null
reg add HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System /v LocalAccountTokenFilterPolicy /t REG_DWORD /d 1 /f | Out-Null
Write-Log 'Token filter policy configured'

if ((Test-Path 'C:\ProgramData\chocolatey') -and -not (Test-Path 'C:\ProgramData\chocolatey\bin\choco.exe') -and -not (Test-Path 'C:\ProgramData\chocolatey\choco.exe')) {
  $backup = 'C:\ProgramData\chocolatey.bak-' + (Get-Date -Format 'yyyyMMddHHmmss')
  Write-Log ('Detected incomplete Chocolatey installation; backing up to ' + $backup)
  Move-Item -Path 'C:\ProgramData\chocolatey' -Destination $backup -Force
}

if (-not (Test-Path 'C:\ProgramData\chocolatey\bin\choco.exe')) {
  Set-ExecutionPolicy Bypass -Scope Process -Force
  [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.SecurityProtocolType]::Tls12
  $env:ChocolateyInstall = 'C:\ProgramData\chocolatey'
  $installerPath = Join-Path $env:TEMP 'devtools-install-chocolatey.ps1'
  Invoke-WebRequest -UseBasicParsing -Uri 'https://community.chocolatey.org/install.ps1' -OutFile $installerPath
  Write-Log ('Chocolatey installer downloaded to ' + $installerPath)
  $installOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installerPath 2>&1
  foreach ($line in $installOutput) {
    Write-Log ('choco-install: ' + $line)
  }
  $installExit = $LASTEXITCODE
  Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
  if ($installExit -ne 0) {
    throw ('Chocolatey install script exited with code ' + $installExit)
  }

  # Handle installer refusing to continue due stale/partial existing directory.
  if ((-not (Test-Path 'C:\ProgramData\chocolatey\bin\choco.exe')) -and (Test-Path 'C:\ProgramData\chocolatey')) {
    $backup = 'C:\ProgramData\chocolatey.bak-' + (Get-Date -Format 'yyyyMMddHHmmss')
    Write-Log ('Chocolatey still missing after install; backing up stale dir to ' + $backup + ' and retrying once')
    Move-Item -Path 'C:\ProgramData\chocolatey' -Destination $backup -Force
    $installerPath = Join-Path $env:TEMP 'devtools-install-chocolatey.ps1'
    Invoke-WebRequest -UseBasicParsing -Uri 'https://community.chocolatey.org/install.ps1' -OutFile $installerPath
    $installOutput = & powershell.exe -NoProfile -ExecutionPolicy Bypass -File $installerPath 2>&1
    foreach ($line in $installOutput) {
      Write-Log ('choco-install-retry: ' + $line)
    }
    $installExit = $LASTEXITCODE
    Remove-Item $installerPath -Force -ErrorAction SilentlyContinue
    if ($installExit -ne 0) {
      throw ('Chocolatey retry install script exited with code ' + $installExit)
    }
  }

  Write-Log 'Chocolatey install script executed'
}

$chocoInstallEnv = [System.Environment]::GetEnvironmentVariable('ChocolateyInstall', 'Machine')
if (-not $chocoInstallEnv) { $chocoInstallEnv = [System.Environment]::GetEnvironmentVariable('ChocolateyInstall', 'User') }

if ((Test-Path 'C:\ProgramData\chocolatey\bin\choco.exe') -or (Test-Path 'C:\ProgramData\chocolatey\choco.exe')) {
  $chocoRoot = 'C:\ProgramData\chocolatey'
} elseif ((Test-Path 'C:\Chocolatey\bin\choco.exe') -or (Test-Path 'C:\Chocolatey\choco.exe')) {
  $chocoRoot = 'C:\Chocolatey'
} elseif ($chocoInstallEnv -and ((Test-Path (Join-Path $chocoInstallEnv 'bin\choco.exe')) -or (Test-Path (Join-Path $chocoInstallEnv 'choco.exe')))) {
  $chocoRoot = $chocoInstallEnv
} else {
  throw ('Chocolatey installation did not produce choco.exe under expected roots. ChocolateyInstall=' + $chocoInstallEnv)
}
Write-Log 'Chocolatey executable verified'

[System.Environment]::SetEnvironmentVariable('ChocolateyInstall', $chocoRoot, 'Machine')
$machinePath = [System.Environment]::GetEnvironmentVariable('PATH', 'Machine')
$chocoBin = Join-Path $chocoRoot 'bin'
if ($machinePath -notlike "*$chocoBin*") {
  [System.Environment]::SetEnvironmentVariable('PATH', $machinePath + ';' + $chocoBin, 'Machine')
}
Write-Log 'Environment variables configured'
Write-Log 'Bootstrap completed successfully'
} catch {
  Write-Log ("ERROR: " + $_.Exception.Message)
  throw
}
EOF

  if [[ $running_in_wsl == true ]]; then
    bootstrap_ps1_windows="$(wslpath -w "$bootstrap_ps1")"
    bootstrap_log_windows="$(wslpath -w "$bootstrap_log")"
  else
    bootstrap_ps1_windows="$(cygpath -w "$bootstrap_ps1")"
    bootstrap_log_windows="$(cygpath -w "$bootstrap_log")"
  fi

  rm -f "$bootstrap_log"

  echo "==> Configuring WinRM and Windows packages (requires elevation)..."
  local bootstrap_rc=0
  if powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
    \$proc = Start-Process powershell.exe -Verb RunAs -Wait -PassThru -ArgumentList @(
      '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', '$bootstrap_ps1_windows', '-LogPath', '$bootstrap_log_windows'
    )
    exit \$proc.ExitCode
  "; then
    bootstrap_rc=0
  else
    bootstrap_rc=$?
    echo "Warning: elevated Windows bootstrap exited with code $bootstrap_rc. Continuing to Ansible for task-level diagnostics." >&2
  fi

  rm -f "$bootstrap_ps1"

  local bootstrap_ready
  bootstrap_ready="$(powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
    try {
      \$t = New-Object Net.Sockets.TcpClient
      \$t.Connect('localhost', 5985)
      \$t.Close()
      \$ltfp = (Get-ItemProperty -Path 'HKLM:\\SOFTWARE\\Microsoft\\Windows\\CurrentVersion\\Policies\\System' -Name 'LocalAccountTokenFilterPolicy' -ErrorAction SilentlyContinue).LocalAccountTokenFilterPolicy
      \$chocoCmd = Get-Command choco.exe -ErrorAction SilentlyContinue
      \$chocoExe = (Test-Path 'C:\\ProgramData\\chocolatey\\bin\\choco.exe') -or (Test-Path 'C:\\ProgramData\\chocolatey\\choco.exe') -or (Test-Path 'C:\\Chocolatey\\bin\\choco.exe') -or (Test-Path 'C:\\Chocolatey\\choco.exe')
      if (\$ltfp -eq 1 -and (\$null -ne \$chocoCmd -or \$chocoExe)) {
        'yes'
      } else {
        \$chocoCmdPresent = [bool](\$null -ne \$chocoCmd)
        'no ltfp=' + \$ltfp + ' choco_cmd=' + \$chocoCmdPresent + ' choco_exe=' + \$chocoExe
      }
    } catch {
      'no exception=' + \$_.Exception.Message
    }
  " | tr -d '\r\n\0' || true)"

  if [[ $bootstrap_ready != yes* ]]; then
    echo "Error: Windows bootstrap preflight is not fully ready." >&2
    echo "Details: $bootstrap_ready" >&2
    if [[ -f $bootstrap_log ]]; then
      echo "Bootstrap log (tail):" >&2
      tail -n 50 "$bootstrap_log" >&2
    fi
    exit 1
  fi
}

# ── Detect OS and architecture ────────────────────────────────────────────────
os_type=""
arch_type=""

running_in_wsl=false
if [[ $OSTYPE == darwin* ]]; then
  os_type="macos"
  case "$(uname -m)" in
  arm64) arch_type="arm64" ;;
  x86_64) arch_type="amd64" ;;
  *) arch_type="$(uname -m)" ;;
  esac
elif [[ $OSTYPE == msys* || $OSTYPE == cygwin* ]]; then
  os_type="windows"
  arch_type="amd64"
elif grep -qi microsoft /proc/version 2> /dev/null; then
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
if [[ $os_type == "macos" ]]; then
  echo "==> Ensuring Python 3 is available..."
  if ! command -v python3 &> /dev/null; then
    echo "Python 3 not found. Install Xcode Command Line Tools and re-run:"
    echo "  xcode-select --install"
    exit 1
  fi

  echo "==> Ensuring pip is up to date..."
  python3 -m ensurepip --upgrade 2> /dev/null || true
  python3 -m pip install --upgrade pip --quiet

  echo "==> Installing Ansible..."
  python3 -m pip install --upgrade ansible --quiet

  # Add user-local bin to PATH if ansible-playbook is not yet visible
  if ! command -v ansible-playbook &> /dev/null; then
    export PATH="$(python3 -m site --user-base)/bin:$PATH"
  fi

# ── Windows bootstrap ─────────────────────────────────────────────────────────
# Ansible does not support Windows as a control node (os.get_blocking is
# unavailable on Windows). WSL is used as the control node; it connects back
# to Windows via WinRM.
elif [[ $os_type == "windows" ]]; then
  if [[ $running_in_wsl == true ]]; then
    # ── Already inside WSL (e.g. re-running after restart when Git Bash broke) ──
    echo "==> Running inside WSL."

    echo "==> Installing Ansible and WinRM dependencies..."
    if [[ ! -x $HOME/.local/bin/uv ]]; then
      curl -LsSf https://astral.sh/uv/install.sh | sh
    fi
    if [[ ! -x $HOME/.ansible-venv/bin/ansible-playbook ]]; then
      rm -rf "$HOME/.ansible-venv"
      $HOME/.local/bin/uv venv --python 3.12 "$HOME/.ansible-venv"
      $HOME/.local/bin/uv pip install --python "$HOME/.ansible-venv/bin/python" \
        ansible pywinrm
    fi

    ensure_windows_bootstrap

    WSL_SCRIPT_DIR="$SCRIPT_DIR"

  else
    # ── Running from Git Bash / msys / cygwin ────────────────────────────────
    echo "==> Checking WSL availability..."

    # Get-WindowsOptionalFeature requires elevation, so we write a PS1, run it
    # elevated, and communicate the result back via a temp file — same pattern
    # used by ensure_windows_bootstrap below.
    _feat_ps1="$(mktemp).ps1"
    _feat_out="$(mktemp)"
    _feat_ps1_win="$(cygpath -w "$_feat_ps1")"
    _feat_out_win="$(cygpath -w "$_feat_out")"

    cat > "$_feat_ps1" << 'FEAT_EOF'
param([string]$Out)
$wsl = (Get-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -ErrorAction SilentlyContinue).State
$vmp = (Get-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -ErrorAction SilentlyContinue).State
if ($wsl -eq 'Enabled' -and $vmp -eq 'Enabled') {
  'already-enabled' | Out-File -FilePath $Out -Encoding ascii -NoNewline
} else {
  $r1 = Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart -WarningAction SilentlyContinue
  $r2 = Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart -WarningAction SilentlyContinue
  if ($r1.RestartNeeded -or $r2.RestartNeeded) {
    'needs-restart' | Out-File -FilePath $Out -Encoding ascii -NoNewline
  } else {
    'enabled-no-restart' | Out-File -FilePath $Out -Encoding ascii -NoNewline
  }
}
FEAT_EOF

    echo "==> Checking WSL Windows features (requires elevation)..."
    powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
      Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList @(
        '-NoProfile', '-ExecutionPolicy', 'Bypass', '-File', '$_feat_ps1_win',
        '-Out', '$_feat_out_win'
      )
    "

    _feat_result="$(cat "$_feat_out" | tr -d '\r\n\0' || true)"
    rm -f "$_feat_ps1" "$_feat_out"

    case "$_feat_result" in
    already-enabled | enabled-no-restart)
      : # features ready; fall through to distro check
      ;;
    needs-restart)
      echo ""
      echo "WSL features enabled. Please restart your computer, then re-run setup."
      exit 0
      ;;
    "")
      echo "Error: WSL feature setup did not complete — UAC prompt cancelled?" >&2
      echo "Re-run setup and accept the elevation prompt to continue." >&2
      exit 1
      ;;
    *)
      echo "Error: unexpected result from WSL feature check: '$_feat_result'" >&2
      echo "Enable manually in an elevated PowerShell, then restart:" >&2
      echo "  Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux" >&2
      echo "  Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform" >&2
      exit 1
      ;;
    esac

    # Features confirmed enabled; check whether a distro is installed.
    _wsl_has_distro=false
    if wsl --list --quiet 2> /dev/null | tr -d '\0' | grep -q .; then
      _wsl_has_distro=true
    fi

    if [[ $_wsl_has_distro == false ]]; then
      echo "==> No WSL distro found. Installing Ubuntu..."
      # Distro installs are per-user and must NOT be run elevated — running via
      # Start-Process -Verb RunAs would register Ubuntu under the Administrator
      # account, making it invisible to the current user.
      # Call wsl.exe directly (not via a powershell.exe wrapper) so Git Bash
      # blocks until the install completes — PowerShell would spawn wsl as a
      # child and return before the download/install finishes.
      wsl.exe --install -d Ubuntu --no-launch 2>&1 | tr -d '\0' || true
      echo ""
      echo "Ubuntu installed. Open the Ubuntu app from the Start menu to complete"
      echo "first-run setup (set a username and password), then close it and re-run"
      echo "this script from Git Bash:"
      echo "  bash '$SCRIPT_DIR/setup.sh'"
      exit 0
    fi

    # WSL + distro exist; check the distro is actually usable (first-run done).
    # If not, auto-create the Linux user non-interactively using wsl -u root
    # (root is always accessible before first-run). Derive the username from the
    # Windows $USERNAME env var and the password from $ANSIBLE_PASSWORD.
    if ! wsl -- echo ok &> /dev/null 2>&1; then
      if [[ -z ${ANSIBLE_PASSWORD:-} ]]; then
        echo "Error: WSL first-run setup is not complete and ANSIBLE_PASSWORD is not set." >&2
        echo "Set ANSIBLE_PASSWORD to your Windows password and re-run setup." >&2
        exit 1
      fi
      _wsl_user="${USERNAME:-devtools}"
      _wsl_user="${_wsl_user,,}" # lowercase
      echo "==> Completing WSL first-run setup (creating user '$_wsl_user')..."
      _wsl_bootstrap_cmd="
        set -e
        # Create user with home dir if they don't already exist.
        id '$_wsl_user' &>/dev/null || useradd -m -s /bin/bash '$_wsl_user'
        # Set password.
        echo '$_wsl_user:$ANSIBLE_PASSWORD' | chpasswd
        # Grant passwordless sudo so subsequent provisioning isn't blocked.
        echo '$_wsl_user ALL=(ALL) NOPASSWD:ALL' > /etc/sudoers.d/90-devtools
        chmod 440 /etc/sudoers.d/90-devtools
        # Set as default WSL user.
        tee /etc/wsl.conf > /dev/null <<'EOF'
[user]
default=$_wsl_user
EOF
      "

      _wsl_bootstrap_tmp="$(mktemp)"
      if ! wsl -u root -- bash -c "$_wsl_bootstrap_cmd" 2>&1 | tr -d '\0' | tee "$_wsl_bootstrap_tmp"; then
        _wsl_bootstrap_out="$(cat "$_wsl_bootstrap_tmp")"
        rm -f "$_wsl_bootstrap_tmp"
        if echo "$_wsl_bootstrap_out" | grep -Eqi 'Catastrophic failure|E_UNEXPECTED'; then
          echo "==> WSL returned E_UNEXPECTED; attempting recovery and one retry..."
          wsl --shutdown 2> /dev/null || true
          powershell.exe -NoProfile -ExecutionPolicy Bypass -Command "
            Start-Process powershell.exe -Verb RunAs -Wait -ArgumentList @(
              '-NoProfile', '-ExecutionPolicy', 'Bypass', '-Command', 'Restart-Service LxssManager -Force'
            )
          "
          _wsl_bootstrap_tmp="$(mktemp)"
          if ! wsl -u root -- bash -c "$_wsl_bootstrap_cmd" 2>&1 | tr -d '\0' | tee "$_wsl_bootstrap_tmp"; then
            _wsl_bootstrap_out="$(cat "$_wsl_bootstrap_tmp")"
            rm -f "$_wsl_bootstrap_tmp"
            echo "Error: WSL first-run setup failed after recovery retry." >&2
            echo "Details: $_wsl_bootstrap_out" >&2
            echo "Try rebooting Windows, then rerun setup." >&2
            exit 1
          fi
          rm -f "$_wsl_bootstrap_tmp"
        else
          echo "Error: WSL first-run setup failed." >&2
          echo "Details: $_wsl_bootstrap_out" >&2
          exit 1
        fi
      else
        rm -f "$_wsl_bootstrap_tmp"
      fi

      # Terminate WSL so the new wsl.conf default user takes effect.
      wsl.exe --terminate Ubuntu 2> /dev/null || true
      echo "==> WSL user '$_wsl_user' created."
    fi

    # Sync the WSL user's Linux password to ANSIBLE_PASSWORD so that sudo works
    # inside WSL if needed. WSL root is accessible without a password from
    # Windows, so this requires no prior credentials.
    if [[ -n $ANSIBLE_PASSWORD ]]; then
      _wsl_user="$(wsl -- whoami | tr -d '\r\n')"
      echo "==> Syncing WSL sudo password for '$_wsl_user'..."
      printf '%s:%s' "$_wsl_user" "$ANSIBLE_PASSWORD" | wsl -u root -- chpasswd
    fi

    echo "==> Installing Ansible and WinRM dependencies inside WSL..."
    # Use uv to create an isolated venv so ansible bins land at a known, fixed
    # path. uv bundles its own Python so no system python3-venv or sudo needed.
    wsl -- bash -c '
      set -e
      if [[ ! -x $HOME/.local/bin/uv ]]; then
        curl -LsSf https://astral.sh/uv/install.sh | sh
      fi
      if [[ ! -x $HOME/.ansible-venv/bin/ansible-playbook ]]; then
        rm -rf "$HOME/.ansible-venv"
        $HOME/.local/bin/uv venv --python 3.12 $HOME/.ansible-venv
        $HOME/.local/bin/uv pip install --python $HOME/.ansible-venv/bin/python \
          ansible pywinrm
      fi
    '

    ensure_windows_bootstrap

    # Translate the Git Bash path (/c/Users/...) to a WSL mount path (/mnt/c/Users/...).
    # Avoid shelling into WSL with a Windows backslash path — argument passing
    # mangles backslashes. Git Bash already gives us a Unix-style path; just
    # remap the leading drive letter.
    WSL_SCRIPT_DIR="$(sed 's|^/\([a-zA-Z]\)/|/mnt/\1/|' <<< "$SCRIPT_DIR")"
  fi
fi

# ── Forward env vars into WSL for Ansible ────────────────────────────────────
# WSLENV lists the Windows env vars WSL should inherit. Variables are
# colon-separated; /u means path-translate (not needed here).
_wslenv="USERNAME:GITHUB_USERNAME:GIT_EMAIL:GIT_NAME:GIT_SIGNING_KEY:GIT_SSH_AGENT:ONEPASSWORD_SSH_KEY"
_wslenv="$_wslenv:DEV_HOME:REPO_HOME:DEVTOOLS_HOME:TOOLS_HOME:TOOLS_BIN_HOME"
_wslenv="$_wslenv:NODE_VERSION:GITHUB_TOKEN:CONTEXT7_API_KEY:ANSIBLE_PASSWORD"

# ── Validate Ansible is available ─────────────────────────────────────────────
if [[ $os_type == "windows" ]]; then
  if ! wsl -- bash -c 'test -x $HOME/.ansible-venv/bin/ansible-playbook' &> /dev/null &&
    [[ $running_in_wsl == false ]]; then
    echo "Error: ansible-playbook not found in WSL venv after installation." >&2
    exit 1
  elif [[ $running_in_wsl == true ]] && [[ ! -x $HOME/.ansible-venv/bin/ansible-playbook ]]; then
    echo "Error: ansible-playbook not found in venv after installation." >&2
    exit 1
  fi
elif ! command -v ansible-playbook &> /dev/null; then
  echo "Error: ansible-playbook not found after installation." >&2
  exit 1
fi

# ── Select inventory and playbook ─────────────────────────────────────────────
inventory=""
playbook=""

if [[ $os_type == "macos" ]]; then
  inventory="$SCRIPT_DIR/ansible/inventory-macos.yml"
  playbook="$SCRIPT_DIR/ansible/site-macos-arm64.yml"
elif [[ $os_type == "windows" ]]; then
  inventory="$WSL_SCRIPT_DIR/ansible/inventory-windows.yml"
  playbook="$WSL_SCRIPT_DIR/ansible/site-windows-amd64.yml"
fi

if [[ $os_type != "windows" && ! -f $playbook ]]; then
  echo "Error: Playbook not found: $playbook" >&2
  exit 1
fi

echo "==> Installing Ansible collections..."
if [[ $os_type == "windows" && $running_in_wsl == false ]]; then
  WSLENV="$_wslenv" wsl -- bash -c "\$HOME/.ansible-venv/bin/ansible-galaxy collection install -r '$WSL_SCRIPT_DIR/ansible/requirements.yml'"
elif [[ $os_type == "windows" && $running_in_wsl == true ]]; then
  "$HOME/.ansible-venv/bin/ansible-galaxy" collection install -r "$SCRIPT_DIR/ansible/requirements.yml"
else
  ansible-galaxy collection install -r "$SCRIPT_DIR/ansible/requirements.yml"
fi

echo "==> Running playbook: $(basename "$playbook")..."
if [[ $os_type == "windows" && $running_in_wsl == false ]]; then
  # In WSL2 the Windows host is the default gateway. Resolve it with a separate
  # wsl call from Git Bash — simple text output, no nested quoting issues.
  _win_host="$(wsl -- ip route show default 2> /dev/null | awk '{print $3; exit}' | tr -d '\r\n\0')"
  # Fallback: ask Windows directly for the vEthernet (WSL) adapter IP.
  if [[ -z $_win_host ]]; then
    _win_host="$(powershell.exe -NoProfile -ExecutionPolicy Bypass -Command \
      "(Get-NetIPAddress -InterfaceAlias 'vEthernet (WSL)' -AddressFamily IPv4 -ErrorAction SilentlyContinue).IPAddress" \
      2> /dev/null | tr -d '\r\n\0')"
  fi
  echo "==> Windows host IP: $_win_host"
  WSLENV="$_wslenv" wsl -- bash -c "\$HOME/.ansible-venv/bin/ansible-playbook \
    -i '$inventory' '$playbook' \
    -e 'devtools_repo_root=$WSL_SCRIPT_DIR' \
    -e 'ansible_host=$_win_host'"
elif [[ $os_type == "windows" && $running_in_wsl == true ]]; then
  _win_host="$(ip route show default 2> /dev/null | awk '{print $3; exit}')"
  "$HOME/.ansible-venv/bin/ansible-playbook" \
    -i "$inventory" \
    "$playbook" \
    -e "devtools_repo_root=$SCRIPT_DIR" \
    -e "ansible_host=$_win_host"
else
  ansible-playbook \
    -i "$inventory" \
    "$playbook" \
    -e "devtools_repo_root=$SCRIPT_DIR"
fi

echo ""
echo "Setup complete."
