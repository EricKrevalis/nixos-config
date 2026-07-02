# todo

the sections below are the real list, each task lives in one with a status:
  [ ] todo   [!] planned   [?] testing   [x] done
TODO and testing at the top just mirror the [!] and [?] items. ideas is the tagged idea pool, done the archive.

refs: https://github.com/swaywm/sway/wiki/Useful-add-ons-for-sway
      https://github.com/Alexays/Waybar/wiki/Examples

## TODO:
- [ ] stylix, parked for now. one base16 palette drives every app, override waybar + sway to keep the hand-tuned look, see docs/colors.md
- [!] dev layer buildout, the editor and toolchains for real productivity, tasks in the dev section.

## testing / work-in-progress:
- [?] cfgs/keybinds in current stack (py, sh, lua, md / nvim / sway / plugins)

## base-layer:

- [ ] calculator (own app or fuzzel calc mode)

## polish-layer:

- [ ] office suite (libreoffice), docx/xlsx/odt/pptx, also csv/rtf, no handler now
- [ ] email client, wires mailto + .eml/mbox/.vcard, all unhandled now
- [ ] calendar, wires .ics + webcal://, unhandled now
- [ ] pdf annotation and forms (zathura is read-only, okular or similar)
- [ ] image editor (gimp or krita), RAW + .xcf, swayimg only views, no edit
- [ ] password manager: bitwarden, no browser extension, rbw + fuzzel (rofi-rbw/fuzzel-rbw), type via wtype not clipboard, argon2id kdf, vaultwarden self-host long-term
- [ ] torrent client, wires magnet:// + .torrent, unhandled now
- [ ] note taking
- [ ] file sync (syncthing or similar)

## specialized layer:

### dev:
- [ ] lsp + completion foundation: servers from nixpkgs (no mason), calm manual completion, nix/lua/bash/python/markdown
- [ ] nvim colorscheme parked for the stylix pass, theme nvim with windows and bars off one palette, not on its own
- [ ] typst: treesitter grammar + tinymist server, typst-preview for live preview
- [ ] latex: treesitter grammar + texlab server + vimtex for build and forward/inverse pdf search
- [ ] jupyter notebooks in neovim (jupytext + molten), needs a graphics-capable terminal for inline output, foot is sixel not kitty graphics
- [ ] per-project dev environments: learn flake devShells + direnv/nix-direnv first, reproducible isolated toolchains per repo, lsp servers from the project shell
- [ ] compare devenv vs plain devShells: devenv adds services/presets but its own cli steps outside flakes, reach for it when a project needs services, not by default
- [ ] revisit python lsp: on basedpyright + ruff now, re-evaluate pyrefly (1.0) and ty (still beta) once they harden
- [ ] docker or podman
- [ ] language toolchains as needed
- [ ] ultra lategame: pi harness, ponytail/caveman, maybe open LLM, huge optimizations

### nvim, to explore later:
- [ ] gitsigns: git gutter signs, stage/reset/navigate hunks, inline blame, complements lazygit's commit view
- [ ] mini.surround: add/change/delete the pair around text, manual so not aggressive
- [ ] treesitter-textobjects: function/class/argument motions, source matched from nix like the grammars
- [ ] telescope-ui-select: route lsp pickers like code actions through telescope, not a bare list
- [ ] fidget: lsp progress spinner
- [ ] trouble: project-wide diagnostics panel
- [ ] luasnip + friendly-snippets: snippet library, blink's builtin covers the basics for now
- [ ] render-markdown: in-buffer markdown rendering
- [ ] docs/nvim.md: write up the dev-layer decisions (treesitter from nix, blink lua matcher, basedpyright + ruff, format on demand)

### gaming:
- [ ] steam rebuilds its shader cache every reboot, re-validates and re-processes vulkan shaders on boot, investigate the cache setup
- [ ] performance pass for the box (cpu, ram, gpu), research what's worth tuning for gaming
- base stack complete (steam + GE-Proton, gamescope, gamemode, vesktop, mangohud), see done

### nvidia:
- [ ] fan/clock control on wayland, nvidia-settings is useless there (needs Xorg), LACT is the lead candidate, research in depth

## hardware / system:

- [ ] udev rules for the input and audio peripherals
- [ ] usb dac control

## maintenance:

cleanup nix doesn't handle on its own.
- [ ] sweep stray dotdirs and ~/.cache bloat that builds up over time
- [ ] decide if a short cleanup guide is worth writing, deeper gc than nix gc (journal, ~/.cache, old downloads)

## audio:

- [ ] test routing between both devices (mic interface and usb dac)

## home-manager:

- [ ] neovim config
- [ ] remaining ssh work (tunnel/jump hosts, per secrets.md). remote resilience: tmux for session persistence, mosh on top only for flaky/roaming links (needs a udp port open), pair mosh with tmux not zellij.

## secrets:

- [ ] add the laptop host key as a recipient in .sops.yaml once that machine exists, then run sops updatekeys on secrets/*

## repo:

- [ ] laptop host: generate hardware config and re-enable in flake.nix

## ideas:

not committed. pull one up into a section above when it's worth doing.

### desktop
- [ ] per-app window rules: workspace assigns, scratchpad terminal
- [ ] window resize/move binds, a dedicated resize mode
- [ ] thunar thumbnails: ffmpegthumbnailer for video, poppler for pdf
- [ ] gtk + qt theming for one consistent look, mismatched now
- [ ] kanshi hotplug profiles, auto-apply the layout on monitor connect (laptop win)
- [ ] volume/brightness osd, only the wiremix tui now
- [ ] keybind cheatsheet overlay
- [ ] caps lock remap, pointer accel/scroll settings
- [ ] emoji picker on a keybind
- [ ] mako do-not-disturb toggle for games and calls
- [ ] per-monitor wallpapers or rotation
- [ ] font rendering knobs (hinting, subpixel)
- [ ] force or auto dark mode across gtk apps
- [ ] cliphist size limit or clear on boot
- [ ] clipboard-only screenshot grab, separate from satty
- [ ] scratch note / quick-capture keybind
- [ ] screen recording (wf-recorder or obs)

### shell + tools
- [ ] eza (ls), tealdeer (tldr), dust + duf, sd, yq, glow
- [ ] jq, still not installed
- [ ] yazi tui file manager
- [ ] atuin shell history, decide deliberately
- [ ] nh + nix-output-monitor for nicer rebuilds
- [ ] nix-tree and nix-index for closure and package spelunking
- [ ] comma, run any nixpkgs program without installing
- [ ] tmux or zellij
- [ ] git commit signing + a global gitignore

### system
- [ ] fstrim for ssd health
- [ ] swap: zram or a real partition, none now
- [ ] earlyoom or systemd-oomd so memory load can't hard-lock the box
- [ ] firewall, confirm what's open
- [ ] systemd-boot configurationLimit so the boot menu stops growing
- [ ] scheduled backups (restic or borg), nothing protected now
- [ ] dns hardening (systemd-resolved, optional doh)
- [ ] vpn (tailscale or wireguard)
- [ ] btrfs/zfs snapshots if the filesystem supports it
- [ ] printing + scanning if the need ever comes up
- [ ] monitor color/icc profiles
- [ ] apparmor, secure boot (lanzaboote), tighter polkit rules
- [ ] ntp/clock format
- [ ] disable the pc speaker beep
- [ ] hdr, parked, not really there on sway yet

## done:

- [x] lsp root_dir falls back to the file's dir, servers attach on loose files not just git repos
- [x] oil q quits back to the previous buffer
- [x] telescope pickers, oil, window splits/buffers, system clipboard both ways, persistent undo verified
- [x] lsp attaches for lua, nix, bash, markdown (python verified)
- [x] blink completion: passive popup, Ctrl-y accepts, enter stays a newline, self. lists lsp items
- [x] conform <leader>cf formats nix/lua/python/bash (after nrs pulls the formatter binaries)
- [x] lualine statusline appears after restart
- [x] <leader>e diagnostic float, and treesitter folds (zM zR za)
- [x] custom autotiler (core/configs/autotile) replaces autotiling-rs, splits from live window geometry not just on focus. resize fires no ipc event, self-corrects on next focus/move
- [x] power menu (fuzzel --dmenu, own config), fires lock/suspend/reboot/shutdown from Mod+Shift+e, the waybar button and the fuzzel entry
- [x] foot replaced alacritty: shift+enter newline in claude, popups float, "open terminal here", no middle-click paste, Ctrl+Shift+R scrollback search
- [x] float dialogs via sway's built-in auto-float, no explicit for_window rule needed
- [x] screen lock (swaylock + swayidle), unlocks and locks before sleep
- [x] xdg-user-dirs recreate on build
- [x] nvidia suspend/resume clean with powerManagement on, tested under load
- [x] layer restructure: leaner base, fzf/fd/bat to dev, mullvad/btop/cliphist to polish, steam rule to gaming, nvidia launch quirks to nvidia.nix
- [x] file type handling tested (md, txt, pdf, images, audio, video)
- [x] firefox prefs in-repo, not hand-pasted into the profile
- [x] firefox extensions via profile (uBlock + theme), not enterprise policy
- [x] thunar open-with read-only fixed (mimeapps.list unmanaged, x-zerosize files pinned to nvim)
- [x] copy/paste: Ctrl+C/V in gui apps, Ctrl+Shift+C/V in the terminal; Shift+Enter newline in prompts
- [x] primary/middle-click clipboard retired, both copy and paste
- [x] images in cliphist
- [x] cpu microcode managed (amd, 0xa201030)
- [x] old flatpak + broken firefox state cleaned; profile in ~/.config/mozilla, arkenfox SUCCESS
- [x] pipewire sample rate + allowed rates (44.1k/48k) + resample quality
- [x] wireplumber mic chain (mic interface only) and dac output (usb dac prioritized)
- [x] mic settings versioned in configs
- [x] mic interface utility daemon enabled
- [x] shell stack: starship, zoxide (cd), fzf, autosuggestion, syntax highlighting; delta + lazygit on the dev layer
- [x] gaming stack: steam + GE-Proton, gamescope, gamemode, vesktop, mangohud, vm.max_map_count bump
- [x] nvidia stable + open kernel modules, validated under load (thermals, suspend/resume, explicit-sync)
- [x] hardware cursors retested under fullscreen xwayland, WLR_NO_HARDWARE_CURSORS stays removed
