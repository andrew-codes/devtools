{ user, pkgs, ... }:

{
  # Determinate already manages the Nix daemon, so nix-darwin shouldn't.
  nix.enable = false;

  nixpkgs.config.allowUnfree = true;
  nixpkgs.hostPlatform = "aarch64-darwin";

  system.primaryUser = user;
  # Nothing else here sets the login shell: home-manager's `programs.zsh` only
  # writes ~/.zshrc, it never touches the account record, so an account whose
  # shell was set to bash out of band stays on bash. nix-darwin does set it,
  # via `dscl . -create /Users/<user> UserShell`, but only for users listed in
  # `knownUsers` -- which is what opts this account into being managed here.
  #
  # The uid/gid have to match the real account or nix-darwin prints "existing
  # user has unexpected uid, skipping" and leaves the shell alone. 501/20 is
  # the first admin account on any Mac, so it's right on a fresh machine;
  # confirm with `id -u` / `id -g` if a switch ever reports that warning.
  #
  # Existing accounts are never re-created -- nix-darwin only runs
  # `sysadminctl -addUser` when the user doesn't exist, and otherwise just
  # updates these properties in place.
  users.knownUsers = [ user ];
  users.users.${user} = {
    uid = 501;
    gid = 20;  # staff
    home = "/Users/${user}";
    shell = pkgs.zsh;
    # Only consulted if nix-darwin ever creates the account rather than
    # adopting one macOS already made, but the option defaults to true and a
    # hidden primary account doesn't appear at the login window.
    isHidden = false;
  };
  # Also list it in /etc/shells, so `chsh` accepts it by hand later.
  environment.shells = [ pkgs.zsh ];
  system.stateVersion = 6;
  system.defaults = {
    NSGlobalDomain = {
      AppleInterfaceStyle = "Dark";
      KeyRepeat = 2;          # fast key repeat
      InitialKeyRepeat = 15;  # short delay before repeat
      _HIHideMenuBar = true;  # auto-hide the menu bar
      AppleShowAllExtensions = true;
    };
    dock.autohide = true;
    finder.FXPreferredViewStyle = "Nlsv";  # list view by default
    finder.CreateDesktop = false;          # clean desktop
    trackpad.Clicking = false;              # tap to click
  };
  # Raycast replaces Spotlight search, so keep Spotlight's own indexing off.
  system.activationScripts.postActivation.text = ''
    mdutil -i off -d / >/dev/null

    # user.signingkey is machine-specific (each dev machine has its own SSH
    # signing key), so it isn't tracked or symlinked by this repo -- it's
    # pulled in via ~/.gitconfig's `[include] path = ~/.gitconfig.local`.
    if [ ! -f "/Users/${user}/.gitconfig.local" ]; then
      echo ""
      echo "==================================================================="
      echo "NEXT STEP: create ~/.gitconfig.local with this machine's git"
      echo "signing key, e.g.:"
      echo ""
      echo "  [user]"
      echo "      signingkey = ssh-ed25519 AAAA..."
      echo "==================================================================="
    fi
  '';
  nix-homebrew = {
    enable = true;
    inherit user;
    autoMigrate = true;
  };
  homebrew = {
    enable = true;
    # "none" leaves Homebrew packages that aren't listed here alone. Anything
    # installed out of band (bash, git, gcc, ghostty, ...) survives a rebuild.
    onActivation.cleanup = "none";
    onActivation.autoUpdate = true;
    onActivation.extraFlags = [ "--force" ];
    brews = [
      "herdr"
      "weaveworks/tap/gitops"
      "datawire/blackbird/telepresence"
      "mas"  # for driving the App Store by hand; see mas-apps.nix
      # nixpkgs also ships tmux, but Homebrew is what's wanted here: it tracks
      # upstream releases closely and builds against the system libraries the
      # terminal already uses. brew bundle no-ops when it's already installed.
      "tmux"
    ];
    casks = [
      "wezterm"
      "claude-code"
      "1password"
      "1password-cli"
      "docker-desktop"
      "raycast"
      "logi-options+"
      "lens"
    ];
    # No `masApps` here on purpose -- brew bundle can't install Mac App Store
    # apps from inside activation. The app list lives in mas-apps.nix and is
    # applied by setup/macOS.sh; that file explains why.
  };
}
