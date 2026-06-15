{ config, lib, pkgs, ... }:

# gaming layer on top of polish, enabled by host.gaming
lib.mkIf config.host.gaming {
  programs.steam = {
    enable = true; # also pulls in 32-bit graphics
    extraCompatPackages = [ pkgs.proton-ge-bin ]; # newest GE-Proton, pick per game in steam
  };

  # steam launch-option wrapper can't inherit caps (nixpkgs#351516), run gamescope directly
  programs.gamescope = {
    enable = true;
    capSysNice = true; # lets gamescope raise its scheduling priority
  };

  # per-title cpu governor + scheduling boost, add gamemoderun to a game's launch options
  programs.gamemode.enable = true;

  # discord fork with working wayland screen share and audio
  environment.systemPackages = [ pkgs.vesktop ];
}
