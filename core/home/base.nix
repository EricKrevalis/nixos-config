{ settings, lib, pkgs, ... }:
let
  mod = "Mod4";
  # papirus-dark reuses the light computer.svg; greys lifted so it shows on the dark desktop:
  #   body #333333->#585858  edge #595959->#6b6b6b  screen #8e8e8e->#999999
  iconTheme = "Papirus-Dark-eric";
  computerSvg = pkgs.writeText "computer.svg" ''
    <svg xmlns="http://www.w3.org/2000/svg" width="22" height="22" version="1.1">
     <rect style="opacity:0.2" width="12" height="16" x="5" y="4.5" rx="1" ry="1"/>
     <rect style="fill:#999999" width="12" height="16" x="5" y="4" rx="1" ry="1"/>
     <rect style="opacity:0.2" width="20" height="16" x="1" y="2.5" rx="1" ry="1"/>
     <path style="fill:#6b6b6b" d="M 1 16 L 1 17 C 1 17.554 1.446 18 2 18 L 20 18 C 20.554 18 21 17.554 21 17 L 21 16 L 1 16 z"/>
     <path style="fill:#585858" d="M 2,2 C 1.446,2 1,2.446 1,3 V 16 H 21 V 3 C 21,2.446 20.554,2 20,2 Z"/>
     <rect style="opacity:0.1;fill:#ffffff" width="20" height=".5" x="1" y="16"/>
     <path style="opacity:0.1;fill:#ffffff" d="M 2,2 C 1.446,2 1,2.446 1,3 v 0.5 c 0,-0.554 0.446,-1 1,-1 h 18 c 0.554,0 1,0.446 1,1 V 3 C 21,2.446 20.554,2 20,2 Z"/>
    </svg>
  '';
  # one scalable copy, matched before the lookup falls through to papirus-dark, so it wins at every size.
  iconThemePkg = pkgs.runCommandLocal "papirus-dark-eric" { } ''
    base=$out/share/icons/${iconTheme}
    mkdir -p "$base/scalable/devices"
    cp ${computerSvg} "$base/scalable/devices/computer.svg"
    {
      echo "[Icon Theme]"
      echo "Name=${iconTheme}"
      echo "Inherits=Papirus-Dark"
      echo "Directories=scalable/devices"
      echo
      echo "[scalable/devices]"
      echo "Context=Devices"; echo "Size=22"; echo "MinSize=8"; echo "MaxSize=512"; echo "Type=Scalable"
    } > "$base/index.theme"
  '';
in

{
  imports = [ ./polish.nix ./specialized/dev.nix ./specialized/gaming.nix ./specialized/arkenfox.nix ]; # each inert unless its toggle is set

  home.username = settings.username;
  home.homeDirectory = "/home/${settings.username}";

  home.pointerCursor = {
    package = pkgs.bibata-cursors;
    name    = "Bibata-Modern-Classic";
    size    = 20;
    sway.enable = true; # writes seat "*" { xcursor_theme = "..."; } into the sway config
  };

  # enabling gtk hands home-manager the settings.ini, so every pref has to be set here.
  # prefer-dark keeps thunar etc dark (was inherited from the old plasma gtk config), primary-paste off kills middle-click paste.
  gtk = {
    enable = true;
    # papirus-dark icon theme, light-on-dark for the dark desktop
    iconTheme = {
      name = iconTheme;
      package = iconThemePkg;
    };
    gtk3.extraConfig = {
      gtk-enable-primary-paste = false;
      gtk-application-prefer-dark-theme = true;
    };
    gtk4.extraConfig = {
      gtk-enable-primary-paste = false;
      gtk-application-prefer-dark-theme = true;
    };
  };

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
    initContent = lib.mkMerge [
      ''
        export PATH="$HOME/.local/bin:$PATH"
      ''
      # --cmd cd makes cd a frecency-aware superset of the builtin, real paths still work
      (lib.mkAfter ''
        eval "$(zoxide init zsh --cmd cd)"
      '')
    ];
  };

  # shell companions wired into zsh: starship prompt and zoxide dir-jump (z).
  programs.starship = {
    enable = true;
    enableZshIntegration = true;
    # the nerd-font-symbols preset is the bulk of the config, kept as data in configs/starship.
    # refresh it after a starship upgrade: starship preset nerd-font-symbols > that file.
    # the tweaks below override it, recursiveUpdate's second arg wins on conflict.
    settings = lib.recursiveUpdate
      (builtins.fromTOML (builtins.readFile ../configs/starship/nerd-font-symbols.toml))
      {
        add_newline = false;    # no blank line between prompts, keeps it compact
        command_timeout = 1000; # ms before a slow module is skipped, avoids prompt stalls
        # » arrow, forest green on success and burnt orange when the last command failed
        character = {
          success_symbol = "[»](#346b30)";
          error_symbol = "[»](#bc4e20)";
        };
      };
  };
  programs.zoxide = {
    enable = true;
    enableZshIntegration = false; # init by hand in initContent, must run after starship
  };
  # the HM foot module ships its own package, so foot comes from here, not systemPackages.
  # server mode left off, enable it later if terminal startup ever feels slow.
  programs.foot = {
    enable = true;
    settings = {
      main = {
        # mono variant keeps icons single-width so columns stay aligned
        font = "AtkynsonMono Nerd Font Mono:size=12";
        # colors left unset, foot's defaults stand in until stylix owns the palette
        # don't auto-copy a selection anywhere (default is primary), the primary-selection path is retired.
        selection-target = "none";
      };
      # shift+enter emits a newline byte (0x0a) instead of submitting, plain enter still sends CR
      text-bindings."\\x0a" = "Shift+Return";
      # no middle-click paste either, the primary-selection mouse path is retired
      mouse-bindings.primary-paste = "none";
    };
  };

  programs.fuzzel = {
    enable = true;
    package = null; # fuzzel is installed system-wide, home-manager only writes the config
    # fuzzel runs Terminal=true apps in xterm by default, xterm isn't installed here.
    # foot takes the command as trailing args, so no -e, just "foot".
    settings.main.terminal = "foot";
  };

  # exo has no built-in helper for foot, so thunar's "open terminal here" errors out
  xdg.dataFile."xfce4/helpers/foot.desktop".text = ''
    [Desktop Entry]
    Type=X-XFCE-Helper
    X-XFCE-Category=TerminalEmulator
    Name=Foot
    X-XFCE-Commands=foot
    X-XFCE-CommandsWithParameter=foot %s
  '';
  xdg.configFile."xfce4/helpers.rc".text = "TerminalEmulator=foot\n";

  # sway base. per-host monitor layout lives in hosts/<host>/home.nix.
  # the session launch is system-level (core/modules/base.nix), not here.
  wayland.windowManager.sway = {
    enable = true;
    package = null; # use the system sway from programs.sway.enable
    config = {
      modifier = mod;
      terminal = "foot";
      menu = "fuzzel"; # Super+D launcher (native wayland, no xwayland)
      startup = [
        # import session vars so user services (polkit agents, etc.) see the wayland socket and session id
        { command = "systemctl --user import-environment XDG_SESSION_ID XDG_SESSION_TYPE WAYLAND_DISPLAY DISPLAY"; }
        { command = "waybar"; }
        # wallpaper file stays out of the repo (licensing), the glob takes any png/jpg/jpeg
        { command = ''swaybg -m fill -i "$(ls /home/${settings.username}/Pictures/wallpaper.* 2>/dev/null | head -n1)"''; }
      ];
      bars = [ ]; # waybar runs from startup, drop the default swaybar

      input."type:keyboard" = {
        repeat_delay = "200"; # ms before a held key starts repeating
        repeat_rate = "60";   # repeats per second once it kicks in
      };

      window = {
        border = 3;
        titlebar = false;
        commands = [
          {
            # foot sets app_id at map time and it never changes, so match on it not title.
            criteria.app_id = "popup-terminal";
            command = "floating enable, resize set 800 500, move position center";
          }
          {
            criteria.app_id = "satty";
            command = "floating enable, resize set 1600 900, move position center";
          }
          # no dialog float rule needed. sway already auto-floats modal, transient, fixed-size and _NET_WM_WINDOW_TYPE dialog/utility/toolbar/splash windows.
        ];
      };

      # floating windows match tiled: same 3px border, no titlebar
      floating = {
        border = 3;
        titlebar = false;
      };

      colors = {
        focused = {
          border      = "#6A5535";
          background  = "#6A5535";
          text        = "#ffffff";
          indicator   = "#6A5535";
          childBorder = "#6A5535";
        };
        unfocused = {
          border      = "#3A2210";
          background  = "#3A2210";
          text        = "#888888";
          indicator   = "#3A2210";
          childBorder = "#3A2210";
        };
        focusedInactive = {
          border      = "#3A2210";
          background  = "#3A2210";
          text        = "#888888";
          indicator   = "#3A2210";
          childBorder = "#3A2210";
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
        "${mod}+Shift+e"       = "exec powermenu"; # power menu, replaces the default exit nag
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
    extraConfig = ''
      # disables the middle-click primary-selection buffer wayland-wide (config-load only, swaymsg rejects it at runtime)
      primary_selection disabled
      corner_radius 6
      shadows enable
      gaps inner 3
      gaps outer 1
    '';
  };

  # screen locker. minimal forest-tinted look now, stylix takes it over later.
  programs.swaylock = {
    enable = true;
    settings = {
      color = "0f2910"; # dark green background while locked
      indicator-radius = 90;
      indicator-thickness = 8;
    };
  };
  # lock the screen before any suspend and on loginctl lock-session (the power menu's lock action).
  # no idle timeout, this desktop only locks on demand or before sleep.
  services.swayidle = {
    enable = true;
    events = {
      before-sleep = "${lib.getExe pkgs.swaylock} -f";
      lock         = "${lib.getExe pkgs.swaylock} -f";
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

  # firefox is the default browser on every host, vanilla unless settings.arkenfox hardens it.
  # no policy here, so no "managed by your organization", the profile stays the user's own.
  programs.firefox.enable = true;

  programs.zathura.enable = true; # mupdf backend bundled, no extra plugin

  programs.mpv = {
    enable = true;
    config.hwdec = "auto-safe"; # host gpu decoder when safe (nvdec here), else software
  };

  # call foot directly, the packaged nvim.desktop wants a default terminal
  xdg.desktopEntries.nvim = {
    name = "Neovim";
    genericName = "Text Editor";
    exec = "foot nvim %F";
    terminal = false;
    mimeType = [ "text/plain" ];
    categories = [ "Utility" "TextEditor" ];
  };

  # power menu in the fuzzel app list, same script as the waybar button and Mod+Shift+e
  xdg.desktopEntries.power-menu = {
    name = "Power";
    exec = "powermenu";
    terminal = false;
    icon = "system-shutdown";
    categories = [ "System" ];
  };

  # loop-mount an iso read-only via udisks (polkit, no sudo), then open it.
  # eject in thunar to unmount, udisks auto-clears the loop.
  home.packages = [
    pkgs.papirus-icon-theme # the base theme the computer-icon overlay inherits from
    # power menu, launched from Mod+Shift+e, the waybar button and the fuzzel entry.
    # fuzzel --dmenu draws the four actions, its own config so the main launcher is untouched.
    # no logout entry, autologin has nowhere to return to.
    # an overlay not a window, so no sway float rule needed.
    (
      let
        menuConfig = pkgs.writeText "fuzzel-powermenu.ini" ''
          [main]
          font=AtkynsonMono Nerd Font Mono:size=22
          hide-prompt=yes
          # without this, focus_follows_mouse makes the menu vanish the moment the pointer leaves it
          exit-on-keyboard-focus-loss=no
          lines=4
          width=16
          horizontal-pad=60
          vertical-pad=30
          inner-pad=14
          line-height=68

          [border]
          width=3
          radius=6

          [key-bindings]
          # testing j/k navigation here, scoped to this config so the launcher keeps them as plain input
          prev=Up k
          next=Down j
          # soak letters into a no-op so a stray key can't filter the hidden list
          cursor-home=a b c d e f g h i l m n o p q r s t u v w x y z space comma period slash semicolon apostrophe bracketleft bracketright backslash

          [colors]
          background=2a1c0ef2
          text=9a8f80ff
          match=d4783aff
          selection=6a5535ff
          selection-text=ffffffff
          selection-match=d4783aff
          border=6a5535ff
        '';
      in
      pkgs.writeShellApplication {
        name = "powermenu";
        runtimeInputs = with pkgs; [ fuzzel systemd ];
        text = ''
          choice=$(printf '%s\n' \
            "󰌾    Lock" \
            "󰒲    Suspend" \
            "󰜉    Reboot" \
            "󰐥    Shutdown" \
            | fuzzel --dmenu --config=${menuConfig}) || exit 0
          case "$choice" in
            *Lock*)     loginctl lock-session ;;
            *Suspend*)  systemctl suspend ;;
            *Reboot*)   systemctl reboot ;;
            *Shutdown*) systemctl poweroff ;;
          esac
        '';
      }
    )
    (pkgs.writeShellApplication {
      name = "iso-mount";
      runtimeInputs = with pkgs; [ udisks2 gnugrep gnused xdg-utils ];
      text = ''
        dev=$(udisksctl loop-setup -r -f "$1" | grep -o '/dev/loop[0-9]*')
        mnt=$(udisksctl mount -b "$dev" | sed -n 's/.* at \(.*\)\.$/\1/p')
        xdg-open "$mnt"
      '';
    })
  ];
  xdg.desktopEntries.iso-mount = {
    name = "Mount ISO";
    exec = "iso-mount %f";
    terminal = false;
    noDisplay = true; # a mime handler, not a launcher entry
    mimeType = [ "application/x-cd-image" "application/x-iso9660-image" ];
  };

  # ~/.config copy is a read-only store symlink thunar can't write to, defaults fall back to ~/.local/share
  xdg.configFile."mimeapps.list".enable = false;
  # a host can override the web handler to its own browser
  xdg.mimeApps = {
    enable = true;
    defaultApplications =
      let
        forEach = desktop: types: lib.genAttrs types (_: desktop);
      in
        forEach "swayimg.desktop" [
          "image/png" "image/jpeg" "image/gif" "image/webp"
          "image/bmp" "image/tiff" "image/avif" "image/heif"
          # swayimg renders these too, else a zathura plugin claims them
          "image/svg+xml" "image/apng" "image/x-tga" "image/jxl"
          # swayimg previews font glyph sheets
          "font/ttf" "font/otf" "application/x-font-ttf"
        ]
        // forEach "org.pwmt.zathura.desktop" [
          "application/pdf" "application/epub+zip"
          "application/vnd.comicbook+zip" "application/x-cbz"
        ]
        // forEach "mpv.desktop" [
          "video/mp4" "video/x-matroska" "video/webm"
          "video/quicktime" "video/x-msvideo" "video/mpeg"
          "audio/mpeg" "audio/flac" "audio/x-wav"
          "audio/ogg" "audio/mp4" "audio/aac" "audio/opus" "audio/x-opus+ogg"
          "application/xspf+xml"
        ]
        // forEach "nvim.desktop" [
          # 0-byte files report x-zerosize
          "application/x-zerosize"
          "text/plain" "text/markdown" "application/json"
          "application/x-shellscript" "text/x-python" "text/x-csrc"
          # textual files with their own mime, they don't inherit text/plain so pin each
          "application/xml" "text/xml" "application/yaml" "text/x-yaml"
          "application/toml" "text/csv" "text/x-log" "text/rust" "text/x-rust"
          "application/x-desktop" "application/javascript" "application/sql"
          # subtitles and diffs are text, edit them in nvim
          "application/x-subrip" "text/vtt" "application/x-ass"
          "text/x-patch" "text/x-diff"
        ]
        // forEach "firefox.desktop" [
          "text/html" "x-scheme-handler/http" "x-scheme-handler/https"
        ]
        // forEach "xarchiver.desktop" [
          # without these, zathura's comicbook plugin grabs zip/tar/7z/rar and can't extract
          "application/zip" "application/x-tar" "application/x-compressed-tar"
          "application/gzip" "application/x-bzip2" "application/x-xz"
          "application/zstd" "application/x-7z-compressed"
          "application/x-rar" "application/vnd.rar"
        ]
        // {
          # folders to thunar, else zathura's comicbook plugin claims inode/directory
          "inode/directory" = "thunar.desktop";
          # terminal for gui-launched Terminal=true apps (nvim), unset by default
          "x-scheme-handler/terminal" = "foot.desktop";
          # double-click an iso to loop-mount it, see the iso-mount handler above
          "application/x-cd-image" = "iso-mount.desktop";
          "application/x-iso9660-image" = "iso-mount.desktop";
        };
  };

  xdg.configFile."waybar/config.jsonc".text = builtins.toJSON {
    layer    = "top";
    position = "top";
    height   = 20;
    "margin-top"   = 0;
    "margin-left"  = 280;
    "margin-right" = 280;
    exclusive = false;
    spacing   = 0;

    "modules-left"   = [ "custom/power" "clock" ];
    "modules-center" = [ "sway/workspaces" ];
    "modules-right"  = [ "tray" "group/connectivity" ];

    "custom/power" = {
      format     = "󰐥";
      tooltip    = false;
      "on-click" = "powermenu";
    };

    "sway/workspaces" = {
      format             = "●";
      "disable-scroll"   = true;
      "persistent-workspaces" = settings.persistentWorkspaces;
    };

    "group/connectivity" = {
      orientation = "horizontal";
      modules     = [ "pulseaudio" "bluetooth" "network" ];
    };

    tray = {
      "icon-size" = 14;
      spacing     = 8;
    };

    pulseaudio = {
      format         = "{volume}% {icon}";
      "format-muted" = "mute 󰝟";
      "format-icons" = { default = [ "󰕿" "󰖀" "󰕾" ]; };
      "on-click"     = "foot --app-id=popup-terminal wiremix";
    };

    bluetooth = {
      format                     = "󰂯";
      "format-connected"         = "󰂱 {device_alias}";
      "format-connected-battery" = "󰂱 {device_alias} {device_battery_percentage}%";
      tooltip    = false;
      "on-click" = "foot --app-id=popup-terminal bluetui";
    };

    network = {
      "format-wifi"        = "󰤨 {essid}";
      "format-ethernet"    = "󰈀";
      "format-disconnected" = "󰤭";
      tooltip    = false;
      "on-click" = "foot --app-id=popup-terminal nmtui";
    };

    clock = {
      format = "{:%Y-%m-%d  %H:%M}";
    };
  };

  xdg.configFile."waybar/style.css".source = ../configs/waybar/style.css;

  xdg.configFile."satty/config.toml".text = ''
    [general]
    early-exit = true
    save-after-copy = true
    output-filename = "/home/${settings.username}/Pictures/screenshot-%Y-%m-%d_%H:%M:%S.png"
    copy-command = "wl-copy"
    initial-tool = "arrow"
    annotation-size-factor = 2
    corner-roundness = 1
    '';

  # createDirectories makes these at activation, ~/Pictures included for the wallpaper and screenshots
  xdg.userDirs = {
    enable = true;
    createDirectories = true;
    desktop = null;     # no desktop icon renderer on sway
    publicShare = null; # nothing serves it without a share daemon
    download = "$HOME/Downloads";
    documents = "$HOME/Documents";
    music = "$HOME/Music";
    pictures = "$HOME/Pictures";
    videos = "$HOME/Videos";
    templates = "$HOME/Templates"; # thunar's create-document menu reads this
  };


  # usb/drive automount, read by thunar-volman
  xfconf.settings.thunar-volman = {
    "automount-drives/enabled" = true;
    "automount-media/enabled" = true;
  };

  home.stateVersion = "26.05";
}
