# todo

rough priority order, lower items lean on earlier ones being stable.

## in progress

- build out the extended, dev, and game tiers with the actual software stack
- push repo to github (secrets and ssh are done, so this is unblocked)

## up next

- bloat audit: review default packages and services, drop anything unused
- test the flake on a clean environment (vm or fresh install)
- prune old system generations once the config is stable

## software stack (extended / dev / game)

extended:
- [ ] terminal image viewer (?)
- [ ] screenshot tool (grimblast or grim + slurp)
- [ ] notification daemon (mako or dunst)
- [ ] network applet or status indicator
- [ ] mpv

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
- [ ] alacritty config
- [ ] remaining ssh work (tunnel/jump hosts, per secrets.md)

## secrets

- [ ] add the laptop host key as a recipient in .sops.yaml once that machine exists, then
      run sops updatekeys on secrets/*

## repo

- [ ] push to github
- [ ] laptop host: generate hardware config and re-enable in flake.nix
