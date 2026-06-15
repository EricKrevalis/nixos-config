{ settings, lib, ... }:
let
  mod = "Mod4";
in

{
  imports = [ ./specialized/dev.nix ]; # inert unless settings.dev = true

  home.username = settings.username;
  home.homeDirectory = "/home/${settings.username}";

  # one block per git host from settings.sshIdentities, IdentitiesOnly so the agent never offers the wrong key.
  # the identities live in flake.nix common, this stays generic.
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
    package = null; # git is installed system-wide, home-manager only writes the config
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
    # rebuild shortcuts. flake referenced explicitly, no /etc/nixos symlink.
    # no #attr, so nixos-rebuild builds nixosConfigurations.<hostname> for the current host.
    shellAliases = {
      nrs = "sudo nixos-rebuild switch --flake ~/.config/nixos";
      nrb = "sudo nixos-rebuild boot --flake ~/.config/nixos";
    };
    initContent = ''
      export PATH="$HOME/.local/bin:$PATH"
    '';
  };

  # shell companions wired into zsh:
  # starship prompt, zoxide dir-jump (z), fzf history (Ctrl+R) and file search (Ctrl+T).
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = true;
  };
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
  };

  programs.alacritty = {
    enable = true;
    package = null; # alacritty is installed system-wide, home-manager only writes the config
    # mono variant keeps icons single-width so columns stay aligned
    settings.font = {
      normal.family = "AtkynsonMono Nerd Font Mono";
      size = 12;
    };
  };

  # sway base. per-host monitor layout lives in hosts/<host>/home.nix.
  # the session launch is system-level (core/modules/base.nix), not here.
  wayland.windowManager.sway = {
    enable = true;
    package = null; # use the system sway from programs.sway.enable
    config = {
      modifier = mod;
      terminal = "alacritty";
      menu = "fuzzel"; # Super+D launcher (native wayland, no xwayland)
      startup = [
        # propagate session vars into the systemd user session
        # so user services (polkit agents, etc.) can see XDG_SESSION_ID and wayland socket vars
        { command = "systemctl --user import-environment XDG_SESSION_ID XDG_SESSION_TYPE WAYLAND_DISPLAY DISPLAY"; }
        { command = "waybar"; }
        # wallpaper file stays out of the repo (licensing), the glob takes any png/jpg/jpeg
        { command = ''swaybg -m fill -i "$(ls /home/${settings.username}/Pictures/wallpaper.* 2>/dev/null | head -n1)"''; }
        { command = "wl-paste --watch cliphist store"; }
        { command = "wl-paste --primary --watch cliphist store"; }
      ];
      bars = [ ]; # waybar runs from startup, drop the default swaybar

      window = {
        border = 1;
        titlebar = false;
        commands = [
          {
            # proton/xwayland windows tile by default, force them fullscreen. class is steam_app_<id>
            criteria.class = "^steam_app_[0-9]+$";
            command = "fullscreen enable";
          }
        ];
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

  # night light. fixed times, no geoclue daemon or location in the repo
  services.gammastep = {
    enable = true;
    provider = "manual";
    dawnTime = "6:00-8:00";
    duskTime = "19:00-21:00";
    temperature = {
      day = 6500;
      night = 1900;
    };
  };

  programs.zathura.enable = true; # mupdf backend bundled, no extra plugin

  programs.mpv = {
    enable = true;
    config.hwdec = "auto-safe"; # host gpu decoder when safe (nvdec here), else software
  };

  # call alacritty directly, the packaged nvim.desktop wants a default terminal
  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    exec = "alacritty -e nvim %F";
    terminal = false;
    mimeType = [ "text/plain" ];
    categories = [ "Utility" "TextEditor" ];
  };

  # default handler per file type: swayimg images, zathura documents, mpv media,
  # neovim text, firefox web
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        forEach = desktop: types: lib.genAttrs types (_: desktop);
      in
        forEach "swayimg.desktop" [
          "image/png" "image/jpeg" "image/gif" "image/webp"
          "image/bmp" "image/tiff" "image/avif" "image/heif"
        ]
        // forEach "org.pwmt.zathura.desktop" [
          "application/pdf" "application/epub+zip"
          "application/vnd.comicbook+zip" "application/x-cbz"
        ]
        // forEach "mpv.desktop" [
          "video/mp4" "video/x-matroska" "video/webm"
          "video/quicktime" "video/x-msvideo" "video/mpeg"
          "audio/mpeg" "audio/flac" "audio/x-wav"
          "audio/ogg" "audio/mp4" "audio/aac"
        ]
        // forEach "nvim.desktop" [
          "text/plain" "text/markdown" "application/json"
          "application/x-shellscript" "text/x-python" "text/x-csrc"
        ]
        // forEach "firefox.desktop" [
          "text/html" "x-scheme-handler/http" "x-scheme-handler/https"
        ];
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
