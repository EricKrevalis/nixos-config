{ settings, config, pkgs, lib, ... }:

# base system plus the sway desktop, every host gets this. the extended and specialized
# tiers are opt in from flake.nix common. gpu is a separate hardware module (nvidia.nix).
let
  # nvidia needs a couple wlroots env vars and an extra sway flag, integrated gpus do not
  # hardware cursors left on, re-add export WLR_NO_HARDWARE_CURSORS=1 if a fullscreen game hides the cursor
  nvidiaEnv = lib.optionalString config.host.nvidia ''
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
  '';
  swayFlags = lib.optionalString config.host.nvidia " --unsupported-gpu";
in
{
  imports = [
    ./options.nix
    ./nvidia.nix # inert unless host.nvidia = true
    ./extended.nix # inert unless host.extended = true
    ./specialized-dev.nix # inert unless host.specializedDev = true
    ./specialized-game.nix # inert unless host.specializedGame = true
  ];

  # per-host settings feed the typed host.* schema in options.nix
  host.nvidia = settings.nvidia;
  host.extended = settings.extended;
  host.specializedDev = settings.specializedDev;
  host.specializedGame = settings.specializedGame;

  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = settings.hostname;
  networking.networkmanager.enable = true; # ships nmtui for terminal Wi-Fi management

  time.timeZone = settings.timezone;

  i18n.defaultLocale = settings.locale;
  # english ui, international formats. no single english locale does all of this, so the
  # categories are split: ISO dates from en_DK, euro + metric + A4 from en_IE.
  i18n.extraLocaleSettings = {
    LC_TIME        = "en_DK.UTF-8"; # YYYY-MM-DD, 24-hour, Monday-first weeks
    LC_MEASUREMENT = "en_IE.UTF-8"; # metric (km, kg)
    LC_PAPER       = "en_IE.UTF-8"; # A4
    LC_MONETARY    = "en_IE.UTF-8"; # euro, formatted as €1,234.56
  };
  # only generate the locales actually used, keeps the closure small.
  i18n.supportedLocales = [
    "C.UTF-8/UTF-8"
    "${settings.locale}/UTF-8"
    "en_DK.UTF-8/UTF-8"
    "en_IE.UTF-8/UTF-8"
  ];

  # autologin on tty1 then exec sway straight away, no display manager. the launch sits at
  # the system level via loginShellInit so it does not depend on which login shell is used.
  programs.sway.enable = true;
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

  programs.firefox.enable = true;

  services.udisks2.enable = true; # drive mounting backend, needed for USB automount and udisksctl

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
    shell = pkgs.zsh; # home-manager configures zsh; this makes it the login shell
  };
  # zsh must be enabled system-wide for the login shell above (adds /etc/shells, completion).
  programs.zsh.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    alacritty # terminal
    fuzzel # launcher
    bluetui # Bluetooth TUI
    wiremix # audio TUI
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
