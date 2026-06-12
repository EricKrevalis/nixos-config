{ pkgs, ... }:

{
  home.username = "eric";
  home.homeDirectory = "/home/eric";

  programs.git = {
    enable = true;
    settings = {
      user.email = "eric.krevalis@gmail.com";
      user.name = "eric";
      init.defaultBranch = "main";
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
    # On TTY1 login, start Sway directly (no display manager).
    profileExtra = ''
      if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
        export WLR_NO_HARDWARE_CURSORS=1
        export GBM_BACKEND=nvidia-drm
        export __GLX_VENDOR_LIBRARY_NAME=nvidia
        export NIXOS_OZONE_WL=1
        exec sway --unsupported-gpu
      fi
    '';
  };

  # Sway config lives here (system enables the binary via programs.sway).
  wayland.windowManager.sway = {
    enable = true;
    package = null; # use the system Sway from programs.sway.enable
    config = {
      modifier = "Mod4"; # Super key
      terminal = "alacritty";
      menu = "fuzzel"; # Super+D launcher (native Wayland, no XWayland)

      # Three 1920x1080 monitors, left -> right. Two are the same model
      # (Zowie XL), so they're pinned by connector. Serials kept for reference
      # in case connectors ever shuffle:
      #   HDMI-A-1 = Zowie XL  (sn GAG02576SL0)   - left,   60Hz
      #   DP-1     = Zowie XL  (sn EBM2M00765SL0) - middle, 240Hz (main)
      #   DP-2     = BenQ RL2455 (sn S4D05178SL0) - right,  60Hz
      output = {
        "HDMI-A-1" = { mode = "1920x1080@60Hz"; position = "0,0"; };
        "DP-1" = { mode = "1920x1080@240Hz"; position = "1920,0"; };
        "DP-2" = { mode = "1920x1080@60Hz"; position = "3840,0"; };
      };

      # Anchor workspaces so each monitor lights up at login and the main
      # (DP-1) holds the primary ones. Easy to re-tune later.
      workspaceOutputAssign = [
        { workspace = "1"; output = "DP-1"; }
        { workspace = "2"; output = "DP-1"; }
        { workspace = "3"; output = "DP-1"; }
        { workspace = "4"; output = "HDMI-A-1"; }
        { workspace = "5"; output = "HDMI-A-1"; }
        { workspace = "6"; output = "DP-2"; }
        { workspace = "7"; output = "DP-2"; }
      ];
    };
  };

  home.packages = with pkgs; [ alacritty fuzzel ];

  home.stateVersion = "26.05";
}
