# Machine profiles: one shared base configuration, plus a small overlay per
# profile that only removes from it.
#
#   personal  everything in the base. The default whenever nothing selects a
#             profile, so existing machines and unflagged runs are unchanged.
#   work      the base minus 1Password and a few tools the work machine does
#             not get, with firstmate taken from andrew-codes' fork
#             (setup/fork-tools.sh).
#
# This is plain data and stays pure -- no files are read at evaluation time.
# Which profile a machine uses is recorded outside the repo by
# setup/profile.sh; flake.nix turns it into a `mac-<profile>` output, and
# rebuild.sh and setup/macOS.sh pick that output.
#
# setup/windows.sh cannot evaluate Nix, so it carries the same overlay by hand
# (WORK_OMIT_WINGET_PACKAGES, WITH_FORK_TOOLS and the
# `[ "$PROFILE" = personal ]` guards).
# Change both together; setup/windows-parity.md records the mapping.
let
  # Every list a profile may remove from. Naming them all here keeps a
  # profile's `remove` from needing to spell out the ones it does not touch.
  noRemovals = {
    brews = [ ];     # homebrew.brews entries, as written in configuration.nix
    casks = [ ];     # homebrew.casks entries
    masApps = [ ];   # names in mas-apps.nix
    packages = [ ];  # home.packages, by package name (lib.getName)
    zshPlugins = [ ]; # oh-my-zsh plugins whose tool the profile drops
    goPackages = [ ]; # home.nix goPackages, by module path without the @version
  };

  mkProfile =
    { remove ? { }
    , # 1Password is more than an install: it supplies the SSH agent socket,
      # the agent.toml key list and the op-ssh-sign commit signer. A profile
      # without the app must also drop those, or every commit fails to sign.
      onePassword ? true
    , # firstmate from the andrew-codes fork, tracking its `main`. A profile
      # that sets this has home.nix (and setup/windows.sh) run
      # setup/fork-tools.sh. no-mistakes is not part of this: every profile
      # installs it from the fork's releases.
      forkTools ? false
    }: {
      remove = noRemovals // remove;
      inherit onePassword forkTools;
    };

  overlays = {
    personal = mkProfile { };

    work = mkProfile {
      onePassword = false;
      forkTools = true;
      remove = {
        brews = [
          "weaveworks/tap/gitops"
          "datawire/blackbird/telepresence"
        ];
        casks = [
          "1password"
          "1password-cli"
          "claude"
          "chatgpt"
        ];
        masApps = [ "Dynamic Wallpaper Library" ];
        packages = [ "kubeseal" "fluxcd" ];
        zshPlugins = [ "fluxcd" ]; # wraps the flux CLI, which work does not get
      };
    };
  };
in
{
  default = "personal";
  names = builtins.attrNames overlays;
  overlay = profile: overlays.${profile};

  # `without removed list` is `list` minus every element named in `removed`.
  without = removed: builtins.filter (x: !(builtins.elem x removed));

  # setup/macOS.sh's Mac App Store list for a profile: one "<id> <name>" line
  # per app in mas-apps.nix that the profile keeps, empty when none remain.
  # mas-apps.nix is not a flake input -- see the comment there for why -- so
  # this is how the profile reaches it.
  masAppLines = profile:
    let
      apps = import ./mas-apps.nix;
      removed = overlays.${profile}.remove.masApps;
      kept = builtins.filter (n: !(builtins.elem n removed)) (builtins.attrNames apps);
    in
    builtins.concatStringsSep "\n" (map (n: "${toString apps.${n}} ${n}") kept);
}
