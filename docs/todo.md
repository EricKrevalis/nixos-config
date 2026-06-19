# todo

----------

links for some sway setup:  
https://github.com/swaywm/sway/wiki/Useful-add-ons-for-sway  
https://github.com/Alexays/Waybar/wiki/Examples  

----------
- [~] test stack per file type (md, txt, pdf, images, audio, video)
- [~] firefox settings in the repo (prefs, not just visuals), not hand-pasted into ~/.mozilla
- [ ] + extensions handling
- [ ] add to extended: calculator, calendar, image editor
- [ ] Ctrl+C, Ctrl+V everywhere, including terminals (excluding vim)
- [ ] Shift+Enter in claude code
- [ ] Disable Primary copy entirely (left mouse button drag) and all references, same with pase (middle mouse button), only feasible to do once Ctrl+C and Ctrl+V is fully functional (AND IN CLIPHIST!)
- [ ] images in cliphist possible?

extended (feature complete desktop, later tier):
- [ ] office suite (libreoffice), opening docx/xlsx/odt/pptx
- [ ] email client
- [ ] calendar
- [ ] pdf annotation and forms (zathura is read-only, okular or similar)
- [ ] image editor (gimp or krita)
- [ ] password manager: bitwarden, no browser extension. rbw + fuzzel (rofi-rbw/fuzzel-rbw), type via wtype not clipboard (cliphist captures it), argon2id kdf. vaultwarden self-host long-term. proton handles email/cloud separately
- [ ] torrent client
- [ ] note taking
- [ ] file sync (syncthing or similar)

dev:
- [ ] editors and lsp tooling
- [ ] jupyter notebooks in neovim (jupytext + molten), needs a graphics-capable terminal for inline output
- [ ] docker or podman
- [ ] language toolchains as needed
- [ ] ultra lategame: pi harness, ponytail/caveman, maybe open LLM, huge optimizations

## hardware / system

- [ ] hardware cursors: removed WLR_NO_HARDWARE_CURSORS, clean on desktop, retest with and without under a fullscreen xwayland game
- [x] cpu microcode: amd microcode is managed (updateMicrocode on via redistributable firmware), running 0xa201030, bios already at that level
- [ ] udev rules for the input and audio peripherals
- [ ] mic interface utility service
- [ ] usb dac control

## maintenance

cleanup nix doesn't handle on its own.
- [x] cleared old flatpak browser junk (~/.var/app) and the broken firefox state (~/.config/mozilla, ~/.cache/mozilla)
- [x] firefox profile lives in ~/.config/mozilla. home-manager writes there on this version (xdg) and firefox 147+ reads it there, so that's the right spot, the ~/.mozilla idea was wrong. arkenfox applies cleanly there, parrot reports SUCCESS.
- [ ] sweep stray dotdirs and ~/.cache bloat that builds up over time
- [ ] decide if a short cleanup guide is worth writing, deeper gc than nixos-collect-garbage (journal, ~/.cache, old downloads)

## audio

- [x] pipewire sample rate + allowed rates (44.1k/48k) and resample quality set, quantum left default
- [x] wireplumber config for the mic chain, goxlr mic only, extra channels hidden
- [x] microphone settings live in the goxlr profile, versioned in configs/goxlr
- [x] wireplumber config for the dac output, g6 prioritized, its capture dropped
- [ ] test routing between both devices

## home manager
- [ ] zsh plugins, prompt (starship or similar)
- [ ] neovim config
- [ ] remaining ssh work (tunnel/jump hosts, per secrets.md)

## secrets
- [ ] add the laptop host key as a recipient in .sops.yaml once that machine exists, then
      run sops updatekeys on secrets/*

## repo
- [ ] laptop host: generate hardware config and re-enable in flake.nix
