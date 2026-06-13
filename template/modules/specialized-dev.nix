{ config, lib, pkgs, ... }:

# dev tools layer on top of extended, enabled by host.specializedDev
lib.mkIf config.host.specializedDev {
  environment.systemPackages = with pkgs; [
    claude-code
  ];
}
