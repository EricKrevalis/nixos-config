{ settings, lib, pkgs, ... }:

# home-side user apps for the polished desktop layer, gated like core/modules/polish.nix.
lib.mkIf settings.polish {
  home.packages = [
    # wrapped to fix chromium shared-memory crash on NixOS + NVIDIA
    (pkgs.symlinkJoin {
      name = "tidal-hifi";
      paths = [ pkgs.tidal-hifi ];
      buildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        wrapProgram $out/bin/tidal-hifi \
          --add-flags "--disable-dev-shm-usage --disable-gpu-sandbox"
      '';
    })
  ];
}
