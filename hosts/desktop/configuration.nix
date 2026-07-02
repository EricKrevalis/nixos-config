{ settings, ... }:

{
  imports = [
    ./hardware-configuration.nix
  ];

  # services.printing.enable = true; # no printer on this machine, uncomment to add one

  # daemon for the goxlr, mic gain/type/routing, the device holds no usable config on its own
  services.goxlr-utility.enable = true;

  # internal drives, always present on this machine
  fileSystems."/run/media/eric/work" = {
    device = "/dev/disk/by-label/work";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };
  fileSystems."/run/media/eric/games" = {
    device = "/dev/disk/by-label/games";
    fsType = "ext4";
    options = [ "defaults" "nofail" ];
  };

  system.stateVersion = "26.05";
}
