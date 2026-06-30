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

tagged brainstorm pool, layer-value prefix. question each before pulling into a section.

- [ ] base-med: per-app window rules (workspace assigns, scratchpad terminal)
- [ ] base-med: window resize/move binds and a dedicated mode
- [ ] base-med: ffmpegthumbnailer for video thumbnails in thunar
- [ ] base-med: pdf/poppler tumbler thumbnailers
- [ ] base-med: gtk theme + icon + cursor via gtk.* in home-manager, consistent look across apps, mismatched now
- [ ] base-med: qt theming to match gtk (qt.enable, platform theme, QT_QPA_PLATFORM=wayland)
- [ ] base-med: kanshi output hotplug profiles, auto-apply layout on connect/disconnect (laptop win)
- [ ] base-med: eza (ls replacement, colors/icons/git, tree mode)
- [ ] base-med: ripgrep (fast gitignore-aware grep, also a telescope backend)
- [ ] base-med: jq (json processor, box currently lacks it)
- [ ] base-med: nh (nicer rebuild/gc wrapper with diff + tree, could replace nrs/nrb)
- [ ] base-med: nix-output-monitor (nom), live build tree, pairs with nh
- [ ] base-med: nixfmt or alejandra, a nix formatter, pick one
- [ ] base-low: on-screen volume/brightness osd (only the wiremix tui now)
- [ ] base-low: smart borders, gaps polish if i want the look
- [ ] base-low: wdisplays gui for quick monitor tweaks
- [ ] base-low: tealdeer (tldr client, fast per-command examples)
- [ ] base-low: caps lock remap (escape or ctrl), other keyd-style remaps beyond the wooting
- [ ] base-low: pointer settings (accel profile, scroll speed, natural scroll)
- [ ] base-low: keybind cheatsheet / help overlay for sway
- [ ] base-low: cliphist clear-on-boot or a size limit
- [ ] base-low: quick clipboard-only screenshot grab, separate from the satty flow
- [ ] base-low: do-not-disturb toggle for mako during games or calls
- [ ] base-low: swaybg per-monitor wallpapers, or rotation
- [ ] base-low: font rendering knobs (hinting, subpixel, fontconfig)
- [ ] base-low: force dark mode across gtk apps, or auto dark/light
- [ ] base-low: emoji/unicode picker on a keybind
- [ ] base-low: alacritty scrollback size + pager keybind
- [ ] base-low: scratch note / quick-capture keybind
- [ ] polish-med: screen recording (wf-recorder or obs, obs pairs with the mic interface)
- [ ] dev-low: yazi (fast keyboard-driven tui file manager)
- [ ] dev-low: atuin (sqlite shell history, timestamps/exit/dir, changes up-arrow, decide deliberately)
- [ ] dev-low: dust (visual du) + duf (pretty df)
- [ ] dev-low: sd (intuitive find-replace), yq (jq for yaml/toml), glow (render markdown in terminal)
- [ ] dev-low: comma, run any nixpkgs program without installing
- [ ] dev-low: nix-tree, explore closure sizes for bloat cutting
- [ ] dev-low: nix-index
- [ ] dev-low: tmux or zellij multiplexer
- [ ] dev-low: git commit signing + a global gitignore
- [ ] system-high: services.fstrim.enable for ssd health
- [ ] system-high: swap config, zram or a real swap, none right now
- [ ] system-high: earlyoom or systemd-oomd so heavy memory load doesn't hard-lock the box
- [ ] system-high: firewall, confirm networking.firewall.enable and what's open
- [ ] system-med: fwupd for firmware/bios updates from linux
- [ ] system-med: boot.loader.systemd-boot.configurationLimit so the boot menu stops growing
- [ ] system-med: scheduled backups (restic or borg), nothing protected in-repo now
- [ ] system-low: btrfs/zfs snapshots if the filesystem supports it
- [ ] system-low: dns hardening (systemd-resolved, optional doh)
- [ ] system-low: printing (cups) + scanning (sane) + avahi discovery, if i ever print
- [ ] system-low: vpn (tailscale or wireguard) for remote access
- [ ] system-low: color profile / icc management for the monitors
- [ ] system-low: hdr, not really there on sway yet, parked
- [ ] system-low: apparmor profiles
- [ ] system-low: secure boot via lanzaboote
- [ ] system-low: polkit rules to tighten what soteria allows without a password
- [ ] system-low: ntp/time sync confirmation, clock format i actually like
- [ ] system-low: disable the pc speaker beep / system bell

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
