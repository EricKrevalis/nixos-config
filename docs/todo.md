# todo

rough priority order, lower items lean on earlier ones being stable.

## in progress

- build out the extended, dev, and game tiers with the actual software stack
- push repo to github (secrets and ssh are done, so this is unblocked)

## up next

- prune old system generations once the config is stable
- add trash can
- add usb auto mount config nix code
- fix nvidia settings not working (no fan control, no monitors)
- add more basic layers programs for full feature functionality
- edit/adjust default programs


## software stack (phase 3)

desktop features still missing, tool choice per feature TBD:
- [ ] clipboard with history
- [ ] notifications
- [ ] screenshots (capture, region, annotate)
- [ ] gui authentication prompts (no polkit agent yet, some prompts fail silently)
- [ ] media key control
- [ ] status bar (network, clock, audio at a glance)
- [ ] night light
- [ ] video playback
- [ ] image viewing
- [ ] pdf viewing
- [ ] archive handling
- [ ] trash, recoverable delete instead of gone forever
- [ ] usb drives auto-mount on plug in (fold in my local change)
- [ ] gpu fan and clock control that works on wayland
- [ ] default app per file type (md, txt, pdf, images, audio, video)
- [ ] firefox config in the repo, not hand-pasted into ~/.mozilla

dev:
- [ ] editors and lsp tooling
- [ ] docker or podman
- [ ] language toolchains as needed

game:
- [ ] steam + proton
- [ ] gamemode
- [ ] gamescope
- [ ] mangohud

## hardware / system

- [ ] gpu testing under real load (games, xwayland) to validate nvidia stable+open
- [ ] hardware cursors: removed WLR_NO_HARDWARE_CURSORS, clean on desktop, retest with and without under a fullscreen xwayland game
- [x] cpu microcode: amd microcode is managed (updateMicrocode on via redistributable firmware), running 0xa201030, bios already at that level
- [ ] kernel choice: weigh zen vs default lts for gaming
- [ ] udev rules for the input and audio peripherals
- [ ] mic interface utility service
- [ ] usb dac control

## audio

- [ ] wireplumber config for the mic chain
- [ ] wireplumber config for the dac output
- [ ] test routing between both devices

## home manager

- [ ] zsh plugins, prompt (starship or similar)
- [ ] neovim config
- [x] alacritty config: atkynson mono nerd font, size 12, package null (system alacritty)
- [ ] remaining ssh work (tunnel/jump hosts, per secrets.md)

## secrets

- [ ] add the laptop host key as a recipient in .sops.yaml once that machine exists, then
      run sops updatekeys on secrets/*

## repo

- [ ] push to github
- [ ] laptop host: generate hardware config and re-enable in flake.nix
