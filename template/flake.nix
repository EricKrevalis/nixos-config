{
  description = "NixOS flake starter, sway desktop with optional nvidia and tiers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, ... }:
    let
      lib = nixpkgs.lib;

      # forking starts here. change these to your own, then drop a
      # hardware-configuration.nix into hosts/nixos/
      common = {
        hostname = "nixos";
        username = "changeme";
        timezone = "Europe/Berlin";
        locale = "en_US.UTF-8";
        gitName = "Your Name";
        gitEmail = "you@example.com";
        nvidia = false; # set true per host for the proprietary nvidia stack
        extended = true; # feature complete desktop for normal use, the recommended default
        specializedDev = false; # dev tools layer on top of extended
        specializedGame = false; # gaming layer on top of extended
      };

      # one call per machine, settings is common merged with per-host overrides, threaded
      # to every module via specialArgs. modules/options.nix is the typed schema these
      # values feed into.
      mkHost = settings: lib.nixosSystem {
        system = settings.system or "x86_64-linux";
        specialArgs = { inherit settings; };
        modules = [
          ./modules/basic.nix
          ./hosts/${settings.hostname}/configuration.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit settings; };
            home-manager.users.${settings.username}.imports = [
              ./home/basic.nix
              ./hosts/${settings.hostname}/home.nix
            ];
          }
        ];
      };
    in
    {
      nixosConfigurations = {
        nixos = mkHost common;

        # add more machines by copying hosts/nixos and overriding settings:
        # laptop = mkHost (common // { hostname = "laptop"; nvidia = false; });
      };
    };
}
