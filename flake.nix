{
  description = "NixOS configuration for desktop and laptop";

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

      # shared by every host, per-host blocks override these
      common = {
        username = "eric";
        timezone = "Europe/Berlin";
        locale = "en_US.UTF-8";
        gitName = "EricKrevalis";
        gitEmail = "eric.krevalis@gmail.com";
        # "<host>" = "<key filename in ~/.ssh>", per-host blocks can extend this
        sshIdentities = {
          "github.com" = "id_ed25519_github";
        };
        polish = false; # the polished, feature complete desktop for normal use
        dev = false; # dev tools layer on top of polish
        gaming = false; # gaming layer on top of polish
        nvidia = false; # the proprietary nvidia gpu stack
        arkenfox = false; # arkenfox-hardened firefox, requires uBlock script handling knowledge and exception management
        persistentWorkspaces = {}; # waybar persistent-workspaces map, empty = none
      };

      # one mkHost call per machine, settings is common merged with per-host overrides,
      # threaded to modules via specialArgs and typed by core/modules/toggles.nix.
      # core/ is the shared engine, doubles as the fork template.
      mkHost = settings: lib.nixosSystem {
        system = settings.system or "x86_64-linux";
        specialArgs = { inherit settings; };
        modules = [
          ./core/modules/base.nix
          ./hosts/${settings.hostname}/configuration.nix
          sops-nix.nixosModules.sops
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.backupFileExtension = "backup";
            home-manager.extraSpecialArgs = { inherit settings; };
            home-manager.users.${settings.username}.imports = [
              ./core/home/base.nix
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
          polish = true;
          dev = true;
          gaming = true;
          arkenfox = true; # arkenfox-hardened firefox, requires uBlock script handling knowledge and exception management
          sshIdentities = common.sshIdentities // {
            "git.haw-hamburg.de" = "id_ed25519_haw";
          };
          persistentWorkspaces = {
            "1" = ["DP-1"]; "2" = ["DP-1"]; "3" = ["DP-1"]; "4" = ["DP-1"];
            "5" = ["HDMI-A-1"]; "6" = ["HDMI-A-1"]; "7" = ["HDMI-A-1"];
            "8" = ["DP-2"]; "9" = ["DP-2"]; "10" = ["DP-2"];
          };
        });

        # laptop out until hosts/laptop/hardware-configuration.nix exists, the stub breaks flake check.
        # re-enable the line below then.
        # laptop = mkHost (common // { hostname = "laptop"; });
      };

      # forkable starter, scaffold a fork with:
      #   nix flake init -t github:EricKrevalis/nixos
      # core/ is the single engine source, shared with the hosts above, so the template never drifts.
      templates.default = {
        path = ./core;
        description = "sway desktop starter, set your values in core/flake.nix common";
      };
    };
}
