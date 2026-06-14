{ settings, lib, ... }:
let
  mod = "Mod4";
in

{
  home.username = settings.username;
  home.homeDirectory = "/home/${settings.username}";

  # one block per git host from settings.sshIdentities, IdentitiesOnly so the agent
  # never offers the wrong key. the identities live in flake.nix common, this stays generic.
  programs.ssh = {
    enable = true;
    enableDefaultConfig = false;
    settings = {
      "*".AddKeysToAgent = "yes";
    } // lib.mapAttrs (host: keyfile: {
      HostName = host;
      User = "git";
      IdentityFile = "~/.ssh/${keyfile}";
      IdentitiesOnly = true;
    }) settings.sshIdentities;
  };

  programs.git = {
    enable = true;
    package = null; # git is installed system-wide; home-manager only writes the config
    settings = {
      user.email = settings.gitEmail;
      user.name = settings.gitName;
      init.defaultBranch = "main";
    };
  };

  programs.zsh = {
    enable = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    # rebuild shortcuts. the flake is referenced explicitly, no /etc/nixos symlink.
    # no #attr means nixos-rebuild builds nixosConfigurations.<hostname> for the current host.
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/.config/nixos-config";
      nrb = "sudo nixos-rebuild boot --flake ~/.config/nixos-config";
    };
    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  programs.alacritty = {
    enable = true;
    package = null; # alacritty is installed system-wide, home-manager only writes the config
    # Mono variant keeps icons single-width so columns stay aligned
    settings.font = {
      normal.family = "AtkynsonMono Nerd Font Mono";
      size = 12;
    };
  };

  # sway base. per-host monitor layout lives in hosts/<host>/home.nix.
  # the session launch is system-level (modules/basic.nix), not here.
  wayland.windowManager.sway = {
    enable = true;
    package = null; # use the system sway from programs.sway.enable
    config = {
      modifier = mod;
      terminal = "alacritty";
      menu = "fuzzel"; # Super+D launcher (native wayland, no xwayland)
      startup = [
        # propagate session vars into the systemd user session so user services
        # (polkit agents, etc.) can see XDG_SESSION_ID and wayland socket vars
        { command = "systemctl --user import-environment XDG_SESSION_ID XDG_SESSION_TYPE WAYLAND_DISPLAY DISPLAY"; }
        { command = "waybar"; }
        { command = "wl-paste --watch cliphist store"; }
        { command = "wl-paste --primary --watch cliphist store"; }
      ];
      window = {
        border = 1;
        titlebar = false;
      };

      colors = {
        focused = {
          border      = "#2d5a27";
          background  = "#2d5a27";
          text        = "#ffffff";
          indicator   = "#2d5a27";
          childBorder = "#2d5a27";
        };
        unfocused = {
          border      = "#1c1c1c";
          background  = "#1c1c1c";
          text        = "#888888";
          indicator   = "#1c1c1c";
          childBorder = "#1c1c1c";
        };
        focusedInactive = {
          border      = "#1c1c1c";
          background  = "#1c1c1c";
          text        = "#888888";
          indicator   = "#1c1c1c";
          childBorder = "#1c1c1c";
        };
        urgent = {
          border      = "#cc3333";
          background  = "#cc3333";
          text        = "#ffffff";
          indicator   = "#cc3333";
          childBorder = "#cc3333";
        };
      };

      keybindings = lib.mkOptionDefault {
        "${mod}+v"             = "exec bash -c 'cliphist list | fuzzel --dmenu | cliphist decode | tee >(wl-copy --primary) | wl-copy'";
        "Print"                = "exec grim - | satty --filename -";
        "Shift+Print"          = "exec grim -g \"$(slurp)\" - | satty --filename -";
        "XF86AudioPlay"        = "exec playerctl play-pause";
        "XF86AudioPause"       = "exec playerctl play-pause";
        "XF86AudioNext"        = "exec playerctl next";
        "XF86AudioPrev"        = "exec playerctl previous";
        "XF86AudioStop"        = "exec playerctl stop";
        "XF86AudioRaiseVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%+";
        "XF86AudioLowerVolume" = "exec wpctl set-volume @DEFAULT_AUDIO_SINK@ 5%-";
        "XF86AudioMute"        = "exec wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
        "XF86AudioMicMute"     = "exec wpctl set-mute @DEFAULT_AUDIO_SOURCE@ toggle";
      };
    };
  };

  services.mako = {
    enable = true;
    settings = {
      default-timeout = 5000;
      border-radius = 4;
    };
  };

  xdg.configFile."waybar/config.jsonc".source = ../configs/waybar/config.jsonc;
  xdg.configFile."waybar/style.css".source   = ../configs/waybar/style.css;

  xdg.configFile."satty/config.toml".text = ''
    [general]
    early-exit = true
    save-after-copy = true
    output-filename = "/home/${settings.username}/Pictures/screenshot-%Y-%m-%d_%H:%M:%S.png"
    copy-command = "wl-copy"
    initial-tool = "arrow"
    annotation-size-factor = 2
    corner-roundness = 4
    '';

  home.file."Pictures/.keep".text = ""; # creates ~/Pictures before the first save

  xdg.configFile."nvim/init.lua".text = ''
    vim.opt.clipboard = "unnamedplus"
  '';

  # usb/drive automount, read by thunar-volman
  xfconf.settings.thunar-volman = {
    "automount-drives/enabled" = true;
    "automount-media/enabled" = true;
  };

  home.stateVersion = "26.05";
}
