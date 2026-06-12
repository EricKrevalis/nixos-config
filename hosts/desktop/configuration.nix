{ config, pkgs, ... }:

{
  imports = [ ./hardware-configuration.nix ];

  # Bootloader
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  networking.hostName = "desktop";
  networking.networkmanager.enable = true;

  time.timeZone = "Europe/Berlin";

  i18n.defaultLocale = "en_US.UTF-8";
  i18n.extraLocaleSettings = {
    LC_ADDRESS        = "de_DE.UTF-8";
    LC_IDENTIFICATION = "de_DE.UTF-8";
    LC_MEASUREMENT    = "de_DE.UTF-8";
    LC_MONETARY       = "de_DE.UTF-8";
    LC_NAME           = "de_DE.UTF-8";
    LC_NUMERIC        = "de_DE.UTF-8";
    LC_PAPER          = "de_DE.UTF-8";
    LC_TELEPHONE      = "de_DE.UTF-8";
    LC_TIME           = "de_DE.UTF-8";
  };

  # Sway (Wayland), replaced KDE Plasma 6 + SDDM.
  # Login: TTY autologin → exec sway (see home/home.nix zsh profileExtra).
  # Fallback: the previous generation still has KDE/SDDM in the boot menu.
  programs.sway.enable = true;
  services.getty.autologinUser = "eric";

  # Keyboard layout (also used by XWayland apps)
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  # GPU: NVIDIA RTX 3060 Ti (Ampere), proprietary driver for Wayland + gaming.
  # Testing the stable branch with the open kernel modules. `open` only swaps the
  # kernel module; both settings use the proprietary userspace driver, not nouveau.
  # Mint ran the closed modules fine, so that's the fallback: if this flickers or
  # breaks on suspend, roll back from the boot menu and set open = false.
  hardware.graphics = {
    enable = true;
    enable32Bit = true; # 32-bit GL for Steam/Proton
  };
  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true; # required for Wayland; enables explicit sync path
    open = true; # testing; fallback is open = false (see above)
    nvidiaSettings = true;
    package = config.boot.kernelPackages.nvidiaPackages.stable; # testing this branch
    powerManagement.enable = false; # enable if suspend/resume corrupts the display
  };

  services.printing.enable = true;

  services.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
  };

  users.users.eric = {
    isNormalUser = true;
    description = "eric";
    extraGroups = [ "networkmanager" "wheel" ];
    shell = pkgs.zsh; # HM configures zsh; this makes it the actual login shell
  };

  # Enabling zsh system-wide is required for users.users.eric.shell = pkgs.zsh
  # to work cleanly (sets up /etc/shells and completion).
  programs.zsh.enable = true;

  programs.firefox.enable = true;

  nixpkgs.config.allowUnfree = true;

  environment.systemPackages = with pkgs; [
    neovim
    git
    claude-code
  ];

  nix.settings = {
    experimental-features = [ "nix-command" "flakes" ];
    auto-optimise-store = true;
  };

  nix.gc = {
    automatic = true;
    dates = "weekly";
    options = "--delete-older-than 30d";
  };

  system.stateVersion = "26.05";
}
