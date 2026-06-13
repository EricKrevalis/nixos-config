{ config, lib, ... }:

# gaming layer on top of extended, enabled by host.specializedGame
lib.mkIf config.host.specializedGame {
  hardware.graphics.enable32Bit = true; # required for Steam/Proton
}
