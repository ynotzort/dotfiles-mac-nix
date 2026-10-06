{
  description = "Minimal macOS Nix setup with nix-darwin + Home Manager";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    nix-darwin = {
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, nix-darwin, home-manager, ... }:
    let
      # The macOS user is read from the environment, so builds need --impure.
      # Under sudo, SUDO_USER is the real user; USER would be root.
      sudoUser = builtins.getEnv "SUDO_USER";
      user = if sudoUser != "" then sudoUser else builtins.getEnv "USER";
      mac =
        if user == "" || user == "root"
        then throw "dotfiles-mac-nix: run with --impure as your own user (got USER='${user}')"
        else nix-darwin.lib.darwinSystem {
          system = "aarch64-darwin";
          specialArgs = { inherit user; };
          modules = [
            ./nix/host.nix
            home-manager.darwinModules.home-manager
            {
              home-manager.useGlobalPkgs = true;
              home-manager.useUserPackages = true;
              home-manager.backupFileExtension = "backup";
              home-manager.extraSpecialArgs = { inherit user; };
              home-manager.users.${user} = import ./nix/user.nix;
            }
          ];
        };
    in
    {
      darwinConfigurations.mac = mac;
    };
}
