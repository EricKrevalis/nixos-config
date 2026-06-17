{ config, lib, pkgs, ... }:

# feature complete desktop on top of base, enabled by host.polish
lib.mkIf config.host.polish {
}
