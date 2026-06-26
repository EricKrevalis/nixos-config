{ pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # backlight control, laptop only. swaylock/swayidle already come from base's home modules.
  programs.sway.extraPackages = with pkgs; [ brightnessctl ];

  system.stateVersion = "26.05";
}
