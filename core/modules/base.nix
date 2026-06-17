{ settings, config, pkgs, lib, ... }:

# base system plus sway desktop, every host.
# polish and specialized layers are opt in from flake.nix common, gated by toggles.nix.
let
  # nvidia needs two wlroots env vars and a sway flag, integrated gpus do not
  # hardware cursors on, re-add WLR_NO_HARDWARE_CURSORS=1 if a game hides the cursor
  nvidiaEnv = lib.optionalString config.host.nvidia ''
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export WLR_RENDERER=gles2
  '';
  swayFlags = lib.optionalString config.host.nvidia " --unsupported-gpu";
in
{
  imports = [
    ./toggles.nix
    ./polish.nix # inert unless host.polish = true
    ./specialized/dev.nix # inert unless host.dev = true
    ./specialized/gaming.nix # inert unless host.gaming = true
    ./specialized/nvidia.nix # inert unless host.nvidia = true
  ];

  # per-host settings feed the typed host.* schema in toggles.nix
  host.polish = settings.polish;
  host.dev = settings.dev;
  host.gaming = settings.gaming;
  host.nvidia = settings.nvidia;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = settings.hostname;
  networking.networkmanager.enable = true; # ships nmtui for terminal Wi-Fi management
  networking.modemmanager.enable = false; # no cellular modem, networkmanager enables it by default

  time.timeZone = settings.timezone;

  i18n.defaultLocale = settings.locale;
  # english ui, international formats. no single english locale does all of this,
  # so the categories are split: ISO dates from en_DK, euro, metric and A4 from en_IE.
  i18n.extraLocaleSettings = {
    LC_TIME        = "en_DK.UTF-8"; # YYYY-MM-DD, 24-hour, Monday-first weeks
    LC_MEASUREMENT = "en_IE.UTF-8"; # metric (km, kg)
    LC_PAPER       = "en_IE.UTF-8"; # A4
    LC_MONETARY    = "en_IE.UTF-8"; # euro, formatted as €1,234.56
  };
  # generate only the locales we use, keeps the closure small
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "${settings.locale}/UTF-8"
    "en_DK.UTF-8/UTF-8"
    "en_IE.UTF-8/UTF-8"
  ];

  # autologin tty1 then exec sway, no display manager.
  # launch is system level via loginShellInit, independent of the login shell.
  programs.sway = {
    enable = true;
    package = pkgs.swayfx;
    extraPackages = [ ]; # we supply our own, laptop re-adds its tools
  };
  # sway's graphical-desktop base turns on speech-dispatcher, it drags in 700+ MiB of tts voices
  services.speechd.enable = false;
  services.getty.autologinUser = settings.username;
  environment.loginShellInit = ''
    if [ -z "$WAYLAND_DISPLAY" ] && [ "$XDG_VTNR" = 1 ]; then
      ${nvidiaEnv}
      # electron/chromium apps render on wayland instead of xwayland
      export NIXOS_OZONE_WL=1
      exec sway${swayFlags}
    fi
  '';

  # accelerated GL for wayland/sway, every gpu needs this
  hardware.graphics.enable = true;

  # graphical polkit agent for gui apps needing elevation, cli falls back to pkttyagent
  security.soteria.enable = true;

  xdg.portal = {
    enable = true;
    wlr.enable = true;
    extraPortals = [ pkgs.xdg-desktop-portal-gtk ];
    # wlr handles screen capture, gtk covers everything else (file picker, inhibit, settings)
    config.sway = {
      default = [ "gtk" ];
      "org.freedesktop.impl.portal.ScreenCast"  = [ "wlr" ];
      "org.freedesktop.impl.portal.Screenshot"  = [ "wlr" ];
    };
    # chooser_type=simple runs slurp directly instead of hunting a dmenu it can't find.
    # 0.8.x needs the "Monitor: " prefix and an absolute slurp path.
    wlr.settings.screencast = {
      chooser_type = "simple";
      chooser_cmd = "${pkgs.slurp}/bin/slurp -f 'Monitor: %o' -or";
    };
  };

  services.udisks2.enable = true; # drive mounting backend, needed for USB automount and udisksctl

  programs.thunar = {
    enable = true;
    plugins = with pkgs; [ thunar-volman thunar-archive-plugin ];
  };
  services.gvfs.enable = true;    # trash, MTP devices, network locations
  services.tumbler.enable = true; # thumbnail generation

  hardware.bluetooth.enable = true; # powers on at boot so paired audio devices reconnect

  # audio, PipeWire instead of PulseAudio
  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.${settings.username} = {
    isNormalUser = true;
    description = settings.username;
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh; # home-manager configures zsh, this makes it the login shell
  };
  # zsh must be enabled system-wide for the login shell above (adds /etc/shells, completion).
  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;

  # keep man pages, skip the nixos manual rebuild and the html/info trees
  documentation = {
    nixos.enable = false;
    doc.enable = false;
    info.enable = false;
  };

  # explicit font set
  fonts = {
    enableDefaultPackages = false;
    packages = with pkgs; [
      noto-fonts                # ui sans and serif, broad latin and ~900 script faces, no cjk
      noto-fonts-cjk-sans       # chinese/japanese/korean sans, base noto ships none
      noto-fonts-cjk-serif      # cjk serif counterpart
      noto-fonts-color-emoji    # emoji
      nerd-fonts.atkynson-mono  # mono, atkinson hyperlegible, terminal and monospace role
      # nerd-fonts.caskaydia-cove # alt mono, patched cascadia code
      # nerd-fonts.sauce-code-pro # alt mono, source code pro
    ];
    # point the generic family aliases at our fonts, otherwise nixos falls back to dejavu
    fontconfig.defaultFonts = {
      sansSerif = [ "Noto Sans" ];
      serif     = [ "Noto Serif" ];
      monospace = [ "AtkynsonMono Nerd Font Mono" ];
      emoji     = [ "Noto Color Emoji" ];
    };
  };

  environment.systemPackages = with pkgs; [
    neovim
    git
    alacritty # terminal
    fuzzel # launcher
    bluetui # bluetooth tui
    wiremix # audio tui
    btop # resource monitor tui
    trashy # recoverable delete
    wl-clipboard # wayland clipboard tools
    cliphist # clipboard history
    libnotify # notify-send for scripted notifications
    grim # wayland screenshot capture
    slurp # region selector, pairs with grim
    satty # screenshot annotation
    playerctl # media key control (MPRIS)
    waybar # status bar
    swaybg # wallpaper renderer for sway
    swayimg # image viewer
    xarchiver # archive manager, thunar right-click frontend
    p7zip # 7z and zip backend xarchiver calls
    unzip # zip extraction
    zip # zip creation
    fd # faster friendlier find
    bat # cat with syntax highlighting
    mullvad-browser # privacy-hardened default browser, safe out of the box
  ];

  services.openssh = {
    enable = true;
    openFirewall = false; # no incoming connections, host key generation only
    settings = {
      PasswordAuthentication = false;
      PermitRootLogin = "no";
    };
  };

  sops.age.sshKeyPaths = [ "/etc/ssh/ssh_host_ed25519_key" ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };
}
