{
  description = "NixOS flake starter, sway desktop with optional nvidia and layers";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { nixpkgs, home-manager, sops-nix, ... }:
    let
      lib = nixpkgs.lib;

      # fork here, set your own values, then drop a hardware-configuration.nix into hosts/nixos/
      common = {
        hostname = "nixos";
        username = "changeme";
        timezone = "Europe/Berlin";
        locale = "en_US.UTF-8";
        gitName = "Your Name";
        gitEmail = "you@example.com";
        # ssh identity per git host, "<host>" = "<key filename in ~/.ssh>"
        sshIdentities = { }; # e.g. "github.com" = "id_ed25519_github";
        # base is always on. flip a layer to true to add it on top.
        polish = false; # the polished, feature complete desktop for normal use
        dev = false; # dev tools layer on top of polish
        gaming = false; # gaming layer on top of polish
        nvidia = false; # the proprietary nvidia gpu stack
        arkenfox = false; # arkenfox-hardened firefox, needs manual uBlock and exception upkeep
      };

      # one call per machine, settings is common merged with per-host overrides
      # threaded to modules via specialArgs, typed by modules/toggles.nix
      mkHost = settings: lib.nixosSystem {
        system = settings.system or "x86_64-linux";
        specialArgs = { inherit settings; };
        modules = [
          ./modules/base.nix
          ./hosts/${settings.hostname}/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit settings; };
            home-manager.users.${settings.username}.imports = [
              ./home/base.nix
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
