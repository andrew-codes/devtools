{
  description = "devtools";

  inputs = {
    # Use `github:NixOS/nixpkgs/nixpkgs-26.05-darwin` to use Nixpkgs 26.05.
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-26.05-darwin";
    # Use `github:nix-darwin/nix-darwin/nix-darwin-26.05` to use Nixpkgs 26.05.
    nix-darwin.url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    home-manager.url = "github:nix-community/home-manager/release-26.05";
    home-manager.inputs.nixpkgs.follows = "nixpkgs";

    nix-homebrew.url = "github:zhaofengli/nix-homebrew";
  };

  outputs = inputs@{ self, nix-darwin, nix-homebrew, home-manager, nixpkgs }:
    let
      # The one username line to change if this isn't your machine.
      # bootstrap.sh offers to rewrite this for you if your macOS username differs.
      user = "andrew";

      profiles = import ./profiles.nix;

      # One system per profile. `profile` reaches configuration.nix and
      # home.nix as a specialArgs value (a string, "personal" or "work"), so
      # evaluation stays pure: nothing here reads a file, and the machine's
      # recorded profile is only used to pick which output to build.
      mkDarwin = profile: nix-darwin.lib.darwinSystem {
        specialArgs = { inherit user profile; };
        modules = [
          ./configuration.nix
          nix-homebrew.darwinModules.nix-homebrew
          home-manager.darwinModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            # home-manager refuses to clobber a file it didn't create, which
            # otherwise aborts the switch on a machine that already has a real
            # ~/.zshrc, ~/.gitconfig, etc. Move the existing file aside as
            # <name>.bak instead of failing.
            home-manager.backupFileExtension = "bak";
            home-manager.extraSpecialArgs = { inherit user profile; };
            home-manager.users.${user} = import ./home.nix;
          }
        ];
      };
    in
    {
      # `mac-<profile>` is what rebuild.sh and setup/macOS.sh build, from the
      # profile recorded in ~/.config/devtools/profile. `mac` predates profiles
      # and stays the personal one, so anything that still names it is unchanged.
      darwinConfigurations =
        builtins.listToAttrs (map
          (profile: { name = "mac-${profile}"; value = mkDarwin profile; })
          profiles.names)
        // { mac = mkDarwin profiles.default; };
    };
}
