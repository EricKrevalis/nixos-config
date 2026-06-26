{ config, lib, ... }:

# proprietary nvidia driver for wayland and gaming, active when host.nvidia = true.
# open = true uses the open kernel modules (Turing/Ampere or newer), still proprietary userspace, not nouveau.
# flicker or broken suspend, set open = false and rebuild.
lib.mkIf config.host.nvidia {
  # base runs sessionPreExec right before launching sway and appends swayLaunchArgs to the command.
  # sway needs the gles2 renderer and --unsupported-gpu on nvidia, integrated gpus do not.
  # hardware cursors on, re-add WLR_NO_HARDWARE_CURSORS=1 here if a game hides the cursor.
  host.sessionPreExec = ''
    export GBM_BACKEND=nvidia-drm
    export __GLX_VENDOR_LIBRARY_NAME=nvidia
    export WLR_RENDERER=gles2
  '';
  host.swayLaunchArgs = [ "--unsupported-gpu" ];

  services.xserver.videoDrivers = [ "nvidia" ];
  hardware.nvidia = {
    modesetting.enable = true; # required for wayland, enables explicit sync path
    open = true; # see header for the closed-module fallback
    nvidiaSettings = true;
    #package = config.boot.kernelPackages.nvidiaPackages.stable; # stable branch
    package = config.boot.kernelPackages.nvidiaPackages.latest; # 610, adds dmabuf mmap on discrete gpus, swap in to test the firefox flicker

    powerManagement.enable = true; # PROVISIONAL: saves/restores vram so suspend resumes clean, test resume under real load
  };

  # btop finds the gpu only via libnvidia-ml, kept off the linker path on nixos
  nixpkgs.overlays = [
    (final: prev: {
      btop = prev.symlinkJoin {
        name = "btop";
        paths = [ prev.btop ];
        nativeBuildInputs = [ prev.makeWrapper ];
        postBuild = ''
          wrapProgram $out/bin/btop --prefix LD_LIBRARY_PATH : /run/opengl-driver/lib
        '';
      };
    })
  ];
}
