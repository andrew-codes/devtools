{ config, lib, pkgs, user, ... }:

let
  dotfiles = "${config.home.homeDirectory}/.dotfiles";
  # Global npm CLIs installed via Volta. Bump a version here to upgrade it;
  # each is a semver range that npm itself resolves and satisfies in place.
  globalNpmPackages = [
    "@earendil-works/pi-coding-agent@^0.83.0" # https://www.npmjs.com/package/@earendil-works/pi-coding-agent
    "gh-axi@^0.1.29"                          # https://www.npmjs.com/package/gh-axi
    "chrome-devtools-axi@^0.1.28"             # https://www.npmjs.com/package/chrome-devtools-axi
    "quota-axi@^0.1.17"                       # https://www.npmjs.com/package/quota-axi
    "npm-axi@^0.1.1"                          # https://www.npmjs.com/package/npm-axi
    "lavish-axi@^0.1.45"                      # https://www.npmjs.com/package/lavish-axi
    "tasks-axi@^0.2.5"                        # https://www.npmjs.com/package/tasks-axi
  ];
  # The subset of the AXI CLIs above that ship an `axi <tool> setup hooks`
  # command: it installs a SessionStart hook so the tool's ambient context
  # (Lavish's live review sessions, the tasks backlog) is in front of the agent
  # from the first turn instead of needing a tool call. Both are documented as
  # explicit opt-in, idempotent, and self-repairing after a reinstall --
  # confirmed against `<tool> setup --help` for the versions pinned above -- so
  # installAxiAgentHooks below can run them on every rebuild. Pi is not one of
  # the harnesses they support; see the axi-ambient-context extension instead.
  axiAmbientContextTools = [ "lavish-axi" "tasks-axi" ];
  # Go modules installed via `go install`, pinned to a released tag. Their
  # own docs lead with an unpinned `curl | sh` from main with no checksum
  # verification; `go install @<tag>` instead goes through Go's module
  # system, which verifies against sum.golang.org.
  goPackages = [
    "github.com/kunchenguid/no-mistakes/cmd/no-mistakes@v1.41.2" # https://github.com/kunchenguid/no-mistakes/releases
    # Pinned to v1.8.0: every v2.x tag (through at least v2.1.1) is broken
    # upstream -- they tagged v2 releases without bumping go.mod's module
    # path to ".../treehouse/v2" as Go's semantic import versioning
    # requires, so `go install` rejects every v2.x ref with "invalid
    # version: module contains a go.mod file, so module path must match
    # major version". Bump this once upstream fixes go.mod on a new tag.
    "github.com/kunchenguid/treehouse@v1.8.0"                     # https://github.com/kunchenguid/treehouse/releases
  ];
  # Secrets referenced by tooling that reads them from the environment --
  # currently the MCP servers in home/.config/mcp/mcp.json. Values never live
  # in this public repo: activation stubs each key into ~/.env (untracked),
  # and zsh sources that file so child processes inherit them. Add a key here
  # when a new config references one.
  #
  # No ATLASSIAN_* keys here on purpose: Jira and Confluence are reached through
  # the twg CLI (installed below), which holds its own OAuth credentials from
  # `twg login` rather than reading an API token from the environment.
  secretEnvVars = [
    "CONTEXT7_API_KEY"   # mcp.json: context7 headers
  ];
  # Atlassian's Teamwork Graph CLI. Agents use this for every Jira and
  # Confluence operation instead of an Atlassian MCP server -- see the rule in
  # home/AGENTS.md. Atlassian ships no nixpkgs package, npm package, or Go
  # module for it, only a shell installer, so this is the one tool here that
  # comes from a downloaded script. Pinning an exact version is what makes that
  # acceptable: the installer resolves a versioned binary and verifies it
  # against Atlassian's published SHA256SUMS for that same version, so nothing
  # floating or unchecked is executed. Bump this to upgrade.
  twgVersion = "1.1.1"; # https://developer.atlassian.com/cloud/twg-cli/getting-started/installation/
in

{
  home.username = user;
  home.homeDirectory = "/Users/${user}";
  home.stateVersion = "24.11";
  home.packages = with pkgs; [
    ripgrep   # fast search
    fd        # fast find
    eza       # modern ls; required by the oh-my-zsh `eza` plugin below, which
              # only defines aliases and silently leaves them all broken when
              # the binary is missing
    fzf       # fuzzy finder
    jq        # json on the command line
    lazygit
    neovim
    yq
    uv
    shfmt
    kubeseal
    gh
    fluxcd     # flux CLI
    kubectl
    terraform
    ansible
    volta      # node.js version management
    # the font everything renders in
    nerd-fonts.hack
  ];
  fonts.fontconfig.enable = true;
  home.sessionVariables.EDITOR = "nvim";
  home.sessionVariables.REPO_HOME = "${config.home.homeDirectory}/developer/repos";
  home.sessionVariables.VOLTA_HOME = "${config.home.homeDirectory}/.volta";
  home.sessionVariables.SSH_AUTH_SOCK = "${config.home.homeDirectory}/.1password/agent.sock";
  home.sessionPath = [
    "${config.home.homeDirectory}/.local/bin" # custom bin/ commands (db, fa, ...) symlinked here
    "${config.home.homeDirectory}/.volta/bin"
    "${config.home.homeDirectory}/go/bin" # go install targets, e.g. no-mistakes
  ];

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;      # ghost text from history
    syntaxHighlighting.enable = true;  # commands turn green when valid

    # oh-my-zsh comes from the nixpkgs `oh-my-zsh` package (no curl|sh clone);
    # home-manager points $ZSH at the store path and sources oh-my-zsh.sh.
    # `theme` is left at its "" default on purpose: an empty ZSH_THEME loads no
    # oh-my-zsh prompt, so starship (below) stays in sole control of the prompt.
    # Autosuggestion and syntax highlighting stay on the native modules above --
    # not re-added here as omz plugins -- to avoid double-loading them.
    oh-my-zsh = {
      enable = true;
      # Kept intentionally conflict-free: the `git` plugin is deliberately
      # omitted because its `gco`/`glg` aliases would shadow the
      # ~/.local/bin scripts of the same name.
      plugins = [
        "sudo"
        "colored-man-pages"
        "pj"
        "docker"
        "yarn"
        "encode64"
        "eza"
        "fluxcd"
        "gh"
        "git-escape-magic"
      ];
    };

    initContent = ''
      # home.sessionPath is applied once per environment in ~/.zshenv, guarded
      # by __HM_SESS_VARS_SOURCED. A shell that inherits that guard but a PATH
      # missing these dirs never re-adds them. That is exactly what happens in
      # herdr panes: the persistent `herdr server` froze an environment with
      # the guard already set and ~/.local/bin absent, and every pane it forks
      # inherits it. Re-add the home bin dirs idempotently for each interactive
      # shell so custom commands (db, gco, ...) resolve everywhere.
      for _d in "$HOME/go/bin" "$HOME/.volta/bin" "$HOME/.local/bin"; do
        case ":$PATH:" in
          *":$_d:"*) ;;
          *) PATH="$_d:$PATH" ;;
        esac
      done
      export PATH
      unset _d

      bindkey '^f' autosuggest-accept

      # Completions for the custom bin/ commands are written as bash-style
      # `complete -F` scripts; bashcompinit lets zsh load them unchanged.
      autoload -U +X bashcompinit && bashcompinit
      for f in ~/.config/zsh/bin-completion/*(N); do
        source "$f"
      done

      # Secrets live in ~/.env (untracked; activation stubs the keys in).
      # `set -a` exports everything it defines, so child processes -- pi, its
      # MCP servers, etc. -- inherit them.
      if [[ -f ~/.env ]]; then
        set -a
        source ~/.env
        set +a
      fi

      # Say so, every shell, until each stubbed secret actually has a value.
      () {
        local var
        local -a missing
        for var in ${lib.concatStringsSep " " secretEnvVars}; do
          if [[ -z ''${(P)var} ]]; then
            missing+=($var)
          fi
        done
        if (( $#missing )); then
          print -u2 "⚠  Unset secrets in ~/.env: ''${(j:, :)missing}"
          print -u2 "   Set them there before using tooling that needs them."
        fi
      }
    '';
    shellAliases = {
      ".." = "cd ..";
      add = "git add .";
      m = "git switch main";
      cc = "claude --dangerously-skip-permissions";
      co = "codex --full-auto";
    };
  };

  programs.starship = {
    enable = true;
    settings = {
      add_newline = false;
      format = "$directory$git_branch$git_status$cmd_duration$line_break$character";
      character = {
        success_symbol = "[❯](purple)";
        error_symbol = "[❯](red)";
      };
      cmd_duration.format = "[$duration]($style) ";
    };
  };

  # Edit-in-place: the real file stays in my repo, ~/.config just points at it.
  home.file = {
    ".agents/skills".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills";
    ".config/wezterm".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/wezterm";
    ".config/nvim".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/nvim";
    ".config/herdr".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/herdr";
    ".config/zsh/bin-completion".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/bin-completion";
    # No ".claude/settings.json" entry here on purpose -- it is applied by
    # home.activation.syncClaudeSettings below, for the same reason
    # ~/.claude.json is: a third-party tool writes into it. `lavish-axi setup
    # hooks` / `tasks-axi setup hooks` add their SessionStart entries to
    # ~/.claude/settings.json, and writeFileSync follows symlinks, so while that
    # path was an out-of-store symlink every hook install landed in the tracked
    # repo file -- rewriting it with a machine-specific absolute path and
    # leaving the checkout permanently dirty.
    # Claude Code reads the same harness sources as pi: skills and subagents use
    # a shared on-disk format, so both harnesses symlink to one source of truth.
    # (MCP servers can't be symlinked into Claude's stateful ~/.claude.json; they
    # are synced from the same mcp.json by home.activation.syncClaudeMcp below.)
    ".claude/skills".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.agents/skills";
    ".claude/agents".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/agents";

    # Keep Pi's credential and runtime state local by linking only authored files.
    ".pi/agent/themes/rose-pine-moon.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/themes/rose-pine-moon.json";
    ".pi/agent/models.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/models.json";
    ".pi/agent/settings.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/settings.json";
    ".pi/agent/extensions/terminal-status-title.js".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions/terminal-status-title.js";
    # Pi's own equivalent of what `<tool> setup hooks` installs for the other
    # harnesses. Pi is not one of the harnesses those commands support, and none
    # of the extensions in .pi/agent/settings.json can stand in for it, so this
    # one is ours; the file header records why.
    ".pi/agent/extensions/axi-ambient-context.js".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/extensions/axi-ambient-context.js";
    ".pi/agent/hook/hooks.yaml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/hook/hooks.yaml";
    # Session-start actions shared by both harnesses: pi runs it from hooks.yaml,
    # Claude Code runs it from .claude/settings.json's SessionStart hook.
    ".pi/agent/hook/session-start.sh".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/hook/session-start.sh";
    # Global subagent definitions: <name>.md files with YAML frontmatter
    # (description/tools/model/etc.) + a markdown prompt body. This exact format
    # is shared by pi-subagents and Claude Code, so both harnesses point at this
    # one source (see the ".claude/agents" symlink below).
    ".pi/agent/agents".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.pi/agent/agents";

    ".claude/CLAUDE.md".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";
    ".codex/AGENTS.md".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/AGENTS.md";

    ".gitignore".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/gitignore";

    # Shared git config, with OS-specific bits (1Password signing path, etc.)
    # pulled in via its own `[include] path = ~/.gitconfig-os`.
    ".gitconfig".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.gitconfig";
    ".gitconfig-os".source =
      config.lib.file.mkOutOfStoreSymlink
        "${dotfiles}/home/${if pkgs.stdenv.isDarwin then ".gitconfig-macos" else ".gitconfig-windows"}";

    ".local/bin/devtools-rebuild".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/rebuild.sh";

    ".config/1Password/ssh/agent.toml".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/1Password/ssh/agent.toml";

    # MCP servers for pi-mcp-adapter (and anything else that reads the
    # standard ~/.config/mcp/mcp.json location). Secrets are referenced via
    # ${VAR}/bearerTokenEnv, never embedded, since this repo is public.
    ".config/mcp/mcp.json".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.config/mcp/mcp.json";

    # Personal host entries live in ~/.ssh/config.local (untracked, Included
    # from here) since this repo is public. OS-specific bits (the 1Password
    # IdentityAgent path on macOS; nothing needed on WSL) come via
    # ~/.ssh/config-os, same split as .gitconfig-os above.
    ".ssh/config".source =
      config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/.ssh/config";
    ".ssh/config-os".source =
      config.lib.file.mkOutOfStoreSymlink
        "${dotfiles}/home/.ssh/${if pkgs.stdenv.isDarwin then "config-macos" else "config-windows"}";
  }
  # Bash utility scripts, symlinked individually into ~/.local/bin (which already
  # holds other unmanaged entries) so home-manager only owns these specific names.
  // builtins.listToAttrs (map
    (name: {
      name = ".local/bin/${name}";
      value.source = config.lib.file.mkOutOfStoreSymlink "${dotfiles}/home/bin/${name}";
    })
    (builtins.attrNames (builtins.readDir ./home/bin)));

  # Global npm CLIs (pi.dev's coding agent, plus the AXI tools its
  # session-start hook invokes): none have a nixpkgs package, and their docs
  # recommend npm with --ignore-scripts (skip install-time lifecycle
  # scripts, a common supply-chain vector) over ad-hoc alternatives.
  # Installed through Volta's npm shim, which pins each to the Node version
  # active at install time -- they keep working even after
  # `volta install node@X` changes the default later. Provisions Node via
  # Volta first if it isn't there yet (defaults to latest LTS), so a fresh
  # machine gets everything working in a single rebuild pass. Each entry in
  # globalNpmPackages above is a semver range; npm itself checks whether the
  # installed version already satisfies it and no-ops if so, so bumping the
  # range is the only thing needed to upgrade.
  home.activation.installGlobalNpmPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # Run in a subshell so the PATH/VOLTA_HOME exports below stay contained and
    # do not leak into later activation steps (all steps share one shell).
    (
      VOLTA="${pkgs.volta}/bin/volta"
      VOLTA_NPM="${config.home.homeDirectory}/.volta/bin/npm"

      # Volta writes a shim per installed binary into ~/.volta/bin, then checks
      # that the new command actually resolves, printing "cannot find command
      # <x>. Please ensure that ~/.volta/bin is available on your PATH" when it
      # doesn't. home.sessionPath puts that directory on PATH for interactive
      # shells, but activation scripts don't get sessionPath or
      # sessionVariables, so during a rebuild the check always fails and every
      # freshly shimmed tool prints the note. The installs themselves succeed;
      # the note is only about this script's PATH. Set both so it stays quiet
      # and so Volta uses the same VOLTA_HOME the shells do.
      export VOLTA_HOME="${config.home.homeDirectory}/.volta"
      export PATH="$VOLTA_HOME/bin:$PATH"

      if [ ! -x "$VOLTA_NPM" ]; then
        $DRY_RUN_CMD "$VOLTA" install node || true
      fi

      if [ -x "$VOLTA_NPM" ]; then
        ${lib.concatMapStringsSep "\n        " (pkg: ''
          $DRY_RUN_CMD "$VOLTA_NPM" install -g --ignore-scripts "${pkg}" || true'') globalNpmPackages}
      fi
    )
  '';

  home.activation.installGoPackages = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    # `go install` shells out to git to resolve VCS versions for modules
    # (e.g. pinned @<tag> refs), and to clang (via cgo) for deps that need a
    # C compiler. Activation scripts don't inherit the interactive shell's
    # PATH, so without this both are invisible and the install fails with
    # "exec: \"git\": executable file not found in $PATH" or the same for
    # clang. /usr/bin carries Xcode Command Line Tools' clang; no need to
    # pull in a separate Nix toolchain for it.
    #
    # Run in a subshell so these exports stay contained. All activation steps
    # share one shell, and prepending /usr/bin here would otherwise leak into
    # later steps -- notably home-manager's own linkGeneration, whose
    # `readlink -e` would then resolve to BSD /usr/bin/readlink (no -e flag)
    # and fail, aborting the entire switch under `set -e`.
    (
      export GOBIN="${config.home.homeDirectory}/go/bin"
      export PATH="${pkgs.git}/bin:/usr/bin:$PATH"
      ${lib.concatMapStringsSep "\n      " (pkg: ''
        $DRY_RUN_CMD ${pkgs.go}/bin/go install "${pkg}" || true'') goPackages}
    )
  '';

  # Install the twg CLI (see twgVersion above for why this is a script and not
  # a package). Lands in ~/.local/bin, which home.sessionPath already exports.
  home.activation.installTwg = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    (
      TWG="${config.home.homeDirectory}/.local/bin/twg"

      # Activation scripts inherit none of the interactive shell's PATH, so the
      # installer's own dependencies have to be handed to it explicitly: curl to
      # download, coreutils for sha256sum/mktemp/uname, /usr/bin for awk and
      # sed. ~/.local/bin goes first for a second reason -- when the installer
      # finds its install dir absent from PATH it appends an `export PATH=...`
      # line to the detected shell profile, and ~/.zshrc here is a read-only
      # symlink into the nix store. Having it already on PATH takes that branch
      # out of play entirely. Subshell so none of this leaks into later
      # activation steps, which share one shell.
      export PATH="${config.home.homeDirectory}/.local/bin:${pkgs.curl}/bin:${pkgs.coreutils}/bin:/usr/bin:/bin"

      # Idempotent by version rather than by presence: re-running the installer
      # works, but re-downloads a 70MB binary every time, and rebuilds are
      # frequent. `twg -v` prints a bare version and works before login.
      INSTALLED=""
      if [ -x "$TWG" ]; then
        INSTALLED="$("$TWG" -v 2>/dev/null | ${pkgs.coreutils}/bin/head -n1)"
      fi

      case "$INSTALLED" in
        *"${twgVersion}"*)
          : # already on the pinned version
          ;;
        *)
          echo "==> Installing twg ${twgVersion}"
          # Flags:
          #   --skip-login  login is an interactive browser OAuth flow; it must
          #     not run inside a rebuild. Run `twg login` once by hand; the
          #     credentials then persist across every later rebuild.
          #   --skip-skills the installer's agent detection writes skill files
          #     into ~/.agents/skills and ~/.claude/skills, both of which are
          #     symlinks into this git repo. Without this it drops untracked
          #     files into the checkout on every fresh install.
          #
          # setsid is load-bearing, not decoration. After downloading, the
          # installer runs `twg setup finalize`, which asks for terms consent
          # with a "Continue? [yes/no]" prompt. It reads that prompt from
          # /dev/tty rather than stdin, so redirecting stdin does not suppress
          # it -- and `sudo darwin-rebuild switch` runs from a real terminal,
          # where it would sit there blocking the whole switch on a keypress.
          # Running in a new session with no controlling terminal makes the
          # installer's own `: < /dev/tty` probe fail, so it takes its
          # non-interactive branch instead. Consent is then recorded below.
          #
          # The finalize step still exits non-zero because it could not ask
          # about consent, so its status says nothing about whether the install
          # worked. Ignore it and judge on the artifact: the binary is
          # downloaded and checksum-verified against Atlassian's published
          # SHA256SUMS well before finalize runs, so it lands either way.
          ${pkgs.curl}/bin/curl -fsSL --retry 2 \
              https://teamwork-graph.atlassian.com/cli/install \
            | ${pkgs.util-linux}/bin/setsid --wait ${pkgs.bash}/bin/bash -s -- \
                --version "${twgVersion}" --skip-login --skip-skills \
            || true
          ;;
      esac

      # Verify against the binary, and record terms consent non-interactively
      # so nothing prompts on any later run. Re-running --agree is a no-op.
      INSTALLED=""
      if [ -x "$TWG" ]; then
        INSTALLED="$("$TWG" -v 2>/dev/null | ${pkgs.coreutils}/bin/head -n1)"
      fi

      case "$INSTALLED" in
        *"${twgVersion}"*)
          "$TWG" consent --agree >/dev/null 2>&1 || true
          ;;
        *)
          # Never fail the switch over this: a network blip or an Atlassian
          # outage must not block an otherwise good rebuild.
          echo "==> WARNING: twg ${twgVersion} is not installed; Atlassian tooling will be unavailable." >&2
          ;;
      esac
    )
  '';

  # Stub every secretEnvVars key into ~/.env without touching values that are
  # already set, so adding a key to that list later tops up an existing file
  # rather than needing a hand edit. The file itself is never tracked.
  home.activation.ensureEnvFile = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    ENV_FILE="${config.home.homeDirectory}/.env"
    GREP="${pkgs.gnugrep}/bin/grep"
    TEE="${pkgs.coreutils}/bin/tee"

    if [ ! -e "$ENV_FILE" ]; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/install -m 600 /dev/null "$ENV_FILE"
      $DRY_RUN_CMD "$TEE" -a "$ENV_FILE" >/dev/null <<< $'# Secrets sourced by zsh on startup. Never commit this file.\n# Quote values containing spaces or shell metacharacters.\n'
    fi

    ${lib.concatMapStringsSep "\n    " (var: ''
      if ! "$GREP" -q '^${var}=' "$ENV_FILE"; then
        $DRY_RUN_CMD "$TEE" -a "$ENV_FILE" >/dev/null <<< '${var}='
        echo "==> Stubbed ${var} in ~/.env -- set its value."
      fi'') secretEnvVars}
  '';

  # Keep Claude Code's MCP servers in sync with the shared mcp.json that pi uses
  # (home/.config/mcp/mcp.json, symlinked to ~/.config/mcp/mcp.json). Claude
  # reads user-scope MCP servers from ~/.claude.json, which also holds auth,
  # history, and per-project state, so it can't be symlinked wholesale. Instead
  # merge the shared servers into its .mcpServers key with jq, leaving every
  # other field -- and any Claude-only servers -- untouched. Same ${VAR}
  # substitution syntax mcp.json already uses is expanded by Claude at runtime.
  # Idempotent: re-running only re-applies the same merge.
  home.activation.syncClaudeMcp = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    CLAUDE_JSON="${config.home.homeDirectory}/.claude.json"
    MCP_SRC="${config.home.homeDirectory}/.config/mcp/mcp.json"
    JQ="${pkgs.jq}/bin/jq"

    if [ -f "$CLAUDE_JSON" ] && [ -f "$MCP_SRC" ]; then
      TMP="$(${pkgs.coreutils}/bin/mktemp)"
      if "$JQ" --slurpfile mcp "$MCP_SRC" \
        '.mcpServers = ((.mcpServers // {}) + $mcp[0].mcpServers)' \
        "$CLAUDE_JSON" > "$TMP"; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$TMP" "$CLAUDE_JSON"
      else
        ${pkgs.coreutils}/bin/rm -f "$TMP"
        echo "==> syncClaudeMcp: jq merge failed; left ~/.claude.json unchanged." >&2
      fi
    fi
  '';

  # Apply this repo's Claude Code settings to ~/.claude/settings.json.
  #
  # This is a copy-and-merge rather than the symlink every other authored file
  # here gets, because ~/.claude/settings.json is not exclusively ours: the
  # `<tool> setup hooks` commands run by installAxiAgentHooks below write their
  # SessionStart entries into it, and their writes follow symlinks. Pointing the
  # path at the repo therefore let a third-party installer rewrite a tracked,
  # public file with a machine-specific absolute path -- the same reason
  # ~/.claude.json is merged rather than linked, and the same reason the twg
  # installer above is invoked with --skip-skills.
  #
  # The tradeoff is that editing home/.config/.claude/settings.json no longer
  # takes effect without a rebuild, unlike the symlinked configs.
  #
  # `$live * $repo` deep-merges with this repo winning, so settings Claude Code
  # writes itself survive. hooks.SessionStart is an array, so the merge replaces
  # it outright and drops the axi entries -- installAxiAgentHooks runs straight
  # after and re-adds them, which is also what keeps a stale hook path repaired
  # after an npm reinstall moves the binaries.
  #
  # Ordered after linkGeneration, not the usual writeBoundary, because this path
  # was a home.file entry until the change above dropped it. On the first switch
  # after that, linkGeneration's orphan cleanup visits ~/.claude/settings.json
  # looking for the previous generation's symlink. Running first would leave it
  # a regular file by then, which the cleanup refuses to delete but reports as
  # "does not link into a Home Manager generation. Skipping delete." Writing
  # after the cleanup keeps that warning off an otherwise clean switch.
  home.activation.syncClaudeSettings = lib.hm.dag.entryAfter [ "linkGeneration" ] ''
    CLAUDE_SETTINGS="${config.home.homeDirectory}/.claude/settings.json"
    SETTINGS_SRC="${dotfiles}/home/.config/.claude/settings.json"
    JQ="${pkgs.jq}/bin/jq"

    if [ -f "$SETTINGS_SRC" ]; then
      $DRY_RUN_CMD ${pkgs.coreutils}/bin/mkdir -p "${config.home.homeDirectory}/.claude"

      # Belt and braces for the generation that drops the old home.file entry:
      # if anything ever leaves a symlink here again, remove it rather than
      # writing through it into the repo.
      if [ -L "$CLAUDE_SETTINGS" ]; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/rm -f "$CLAUDE_SETTINGS"
      fi

      # A missing current file merges against an empty object, so a fresh
      # machine and a re-run take the same path. /dev/null can't stand in for
      # it: `jq -s` would slurp a one-element array and shift the operands.
      TMP="$(${pkgs.coreutils}/bin/mktemp)"
      EMPTY="$(${pkgs.coreutils}/bin/mktemp)"
      echo '{}' > "$EMPTY"
      CURRENT="$EMPTY"
      if [ -f "$CLAUDE_SETTINGS" ]; then
        CURRENT="$CLAUDE_SETTINGS"
      fi

      if "$JQ" -s '.[0] * .[1]' "$CURRENT" "$SETTINGS_SRC" > "$TMP"; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/mv "$TMP" "$CLAUDE_SETTINGS"
      else
        ${pkgs.coreutils}/bin/rm -f "$TMP"
        echo "==> syncClaudeSettings: jq merge failed; left ~/.claude/settings.json unchanged." >&2
      fi
      ${pkgs.coreutils}/bin/rm -f "$EMPTY"
    fi
  '';

  # Install the AXI SessionStart hooks for every harness the tools themselves
  # support: Claude Code (~/.claude/settings.json), Codex (~/.codex/hooks.json
  # plus the [features] hooks flag in ~/.codex/config.toml), OpenCode, and
  # GitHub Copilot CLI. Letting each tool own its own wiring keeps this repo out
  # of the business of hand-writing four harnesses' hook formats, and each
  # command is idempotent and repairs a stale binary path, so running it on
  # every rebuild is a no-op once everything is in place.
  #
  # Ordered after the npm installs (the binaries have to exist) and after
  # syncClaudeSettings, whose merge drops the SessionStart entries these
  # commands then put back.
  #
  # Pi gets the same context from home/.pi/agent/extensions/axi-ambient-context.js
  # instead; none of these tools support it as a hook target.
  home.activation.installAxiAgentHooks =
    lib.hm.dag.entryAfter [ "installGlobalNpmPackages" "syncClaudeSettings" ] ''
      # Subshell so the exports stay contained; all activation steps share one
      # shell. Volta's own shims need VOLTA_HOME, and the tools resolve the hook
      # command they write by looking themselves up on PATH.
      (
        export VOLTA_HOME="${config.home.homeDirectory}/.volta"
        export PATH="$VOLTA_HOME/bin:$PATH"

        # Skipped rather than fatal when a binary is missing, and never fatal on
        # failure: an optional context integration must not fail the switch.
        for tool in ${lib.concatStringsSep " " axiAmbientContextTools}; do
          if [ -x "$VOLTA_HOME/bin/$tool" ]; then
            $DRY_RUN_CMD "$VOLTA_HOME/bin/$tool" setup hooks >/dev/null \
              || echo "==> WARNING: \`$tool setup hooks\` failed; agents start without its ambient context." >&2
          fi
        done
      )
    '';
}
