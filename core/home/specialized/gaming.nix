{ settings, lib, ... }:

# home-side gaming tooling, gated like core/modules/specialized/gaming.nix.
lib.mkIf settings.gaming {
  # proton/xwayland windows tile by default, force them fullscreen. class is steam_app_<id>
  wayland.windowManager.sway.config.window.commands = [
    {
      criteria.class = "^steam_app_[0-9]+$";
      command = "fullscreen enable";
    }
  ];

  # enable installs mangohud and manages the conf, so the package isn't in systemPackages
  programs.mangohud = {
    enable = true;
    settings = {
      fps = true;
      frametime = true;
      frame_timing = false; # the stutter graph
      gpu_stats = true;
      gpu_temp = true;
      cpu_stats = true;
      cpu_temp = true;
      vram = true; 
      ram = true;
      gamemode = false; # confirms gamemode actually engaged

      position = "top-left";
      font_size = 14;
      width = 150;
      alpha = 0.35;
      background_alpha = 0.25;
      fps_sampling_period = 500; # default, but changes CPU draw
      toggle_hud = "Shift_R+F12";
    };
  };
}
