{
  description = "NixOS configuration for desktop and laptop";

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

      # shared by every host, per-host blocks override these
      common = {
        username = "eric";
        timezone = "Europe/Berlin";
        locale = "en_US.UTF-8";
        gitName = "EricKrevalis";
        gitEmail = "eric.krevalis@gmail.com";
        nvidia = false; # set true per host for the proprietary nvidia stack
        extended = false; # feature complete desktop for normal use
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
        desktop = mkHost (common // {
          hostname = "desktop";
          nvidia = true; # RTX 3060 Ti
          extended = true;
          specializedDev = true;
          specializedGame = true;
        });

        # laptop stays out until hosts/laptop/hardware-configuration.nix exists, the stub
        # cannot evaluate and would break nix flake check. re-enable the line below then.
        # laptop = mkHost (common // { hostname = "laptop"; });
      };

      # forkable starter, scaffold a new repo with nix flake init -t github:owner/repo
      templates.default = {
        path = ./template;
        description = "sway desktop starter, set your values in flake.nix common";
      };
    };
}
