# todo

rough priority order, lower items lean on earlier ones being stable.

## in progress

- finish the base layer: feature complete, debloated, settings optimized and personalized.

## up next

- prune old system generations once the config is stable
- fix nvidia settings not working (no fan control, no monitors)
- edit/adjust default programs, question each one
- full basic stack customization pass: once all features are installed, go back and tune settings, keybinds, and config files for every tool (sway, mako, satty, alacritty, fuzzel, etc.)


## software stack, ~ means testing
### noted links for research: https://github.com/swaywm/sway/wiki/Useful-add-ons-for-sway  https://github.com/Alexays/Waybar/wiki/Examples
desktop features, tool choice per feature TBD:

done: clipboard history, notifications, gui auth (soteria), media keys, night light, video playback (mpv), trash (trashy), usb auto-mount (thunar-volman), keyboard repeat (200ms/60Hz), shell stack (zoxide as cd, fzf, starship » arrows + nerd-font preset)

- [~] screenshots, needs tuning after first use (grim, slurp, satty)
- [~] status bar (network, clock, audio at a glance)
- [~] image viewing
- [~] pdf viewing
- [~] archive handling
- [~] default app per file type (md, txt, pdf, images, audio, video)
- [ ] gpu fan and clock control that works on wayland (LACT is the tool, deferred to the gaming module, only worth it if performance turns out bad)
- [ ] firefox settings in the repo (prefs, not just visuals), not hand-pasted into ~/.mozilla
- [ ] configure visuals (mouse cursor, bars, etc.)
- [ ] sway tiling functionality (how they split) + fix not being able to grab them without titlebars
- [ ] ...

extended (feature complete desktop, later tier):
- [ ] office suite (libreoffice), opening docx/xlsx/odt/pptx
- [ ] email client
- [ ] calendar
- [ ] pdf annotation and forms (zathura is read-only, okular or similar)
- [ ] image editor (gimp or krita)
- [ ] music player with a library, if mpv playback proves not enough
- [ ] password manager
- [ ] torrent client
- [ ] note taking
- [ ] file sync (syncthing or similar)

dev:
- [ ] editors and lsp tooling
- [ ] jupyter notebooks in neovim (jupytext + molten), needs a graphics-capable terminal for inline output
- [ ] docker or podman
- [ ] language toolchains as needed
- [ ] fix claude fullscreen render in terminal

game:
- [x] steam + proton
- [x] gamemode
- [x] gamescope
- [x] mangohud

## hardware / system

- [ ] gpu testing under real load (games, xwayland) to validate nvidia stable+open
- [ ] hardware cursors: removed WLR_NO_HARDWARE_CURSORS, clean on desktop, retest with and without under a fullscreen xwayland game
- [x] cpu microcode: amd microcode is managed (updateMicrocode on via redistributable firmware), running 0xa201030, bios already at that level
- [ ] kernel choice: weigh zen vs default lts for gaming
- [ ] udev rules for the input and audio peripherals
- [ ] mic interface utility service
- [ ] usb dac control

## audio

- [x] pipewire sample rate + allowed rates (44.1k/48k) and resample quality set, quantum left default
- [x] wireplumber config for the mic chain, goxlr mic only, extra channels hidden
- [x] microphone settings live in the goxlr profile, versioned in configs/goxlr
- [x] wireplumber config for the dac output, g6 prioritized, its capture dropped
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
