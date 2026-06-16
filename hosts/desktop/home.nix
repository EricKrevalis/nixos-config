{ lib, pkgs, ... }:

{
  # HDMI-A-1 = Zowie XL    (sn GAG02576SL0)    left,   60Hz
  # DP-1     = Zowie XL    (sn EBM2M00765SL0)  middle, 240Hz (main)
  # DP-2     = BenQ RL2455 (sn S4D05178SL0)    right,  60Hz
  wayland.windowManager.sway.extraConfig = ''
    output HDMI-A-1 mode 1920x1080@60Hz position 0,0
    output DP-1 mode 1920x1080@240Hz position 1920,0
    output DP-2 mode 1920x1080@60Hz position 3840,0
    workspace 1 output DP-1
    workspace 2 output DP-1
    workspace 3 output DP-1
    workspace 4 output DP-1
    workspace 5 output HDMI-A-1
    workspace 6 output HDMI-A-1
    workspace 7 output HDMI-A-1
    workspace 8 output DP-2
    workspace 9 output DP-2
    workspace 10 output DP-2
    workspace number 1
  '';

  # pin notifications to the main monitor
  services.mako.settings.output = "DP-1";

  # generic audio drop-in only, device-specific ones are in configs/wireplumber
  xdg.configFile."wireplumber/wireplumber.conf.d".source = ../../configs/wireplumber;

  # pipewire daemon drop-in, clock rate and resampler quality
  xdg.configFile."pipewire/pipewire.conf.d/99-sample-rate.conf".source = ../../configs/pipewire/99-sample-rate.conf;

  # sync the goxlr profile, mic profile and presets from the repo on every rebuild
  # copy not symlink, the daemon rewrites this dir at runtime so it cannot be read-only
  # repo wins each build, tweak it in the UI then copy back here to keep a change
  home.activation.syncGoxlr = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
    src=${../../configs/goxlr}
    data="$HOME/.local/share/goxlr-utility"
    cfg="$HOME/.config/goxlr-utility"
    run mkdir -p "$data" "$cfg"
    run cp -r --no-preserve=mode "$src/profiles" "$src/mic-profiles" "$src/presets" "$data/"
    run cp --no-preserve=mode "$src/settings.json" "$cfg/settings.json"
    # hot-load the refreshed profiles by name, no-ops if the daemon is not up yet
    run ${pkgs.goxlr-utility}/bin/goxlr-client profiles device load Default || true
    run ${pkgs.goxlr-utility}/bin/goxlr-client profiles microphone load DEFAULT || true
  '';
}
