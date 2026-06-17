{ settings, lib, pkgs, ... }:

# home-side user apps for the polished desktop layer, gated like core/modules/polish.nix.
lib.mkIf settings.polish {
  home.packages = with pkgs; [
    tidal-hifi
  ];
}
