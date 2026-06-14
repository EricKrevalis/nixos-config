{ config, lib, pkgs, ... }:

# feature complete desktop on top of basic, enabled by host.extended
lib.mkIf config.host.extended {
}
