# hardware optimizations

what's tuned for performance or hardware health, where it lives, why, and which machine it
applies to. most of this is base layer (every host), a few bits are desktop only.

## cpu

- **amd microcode** (`hosts/desktop`, desktop): the 5950X gets its firmware microcode loaded
  at boot. version 0xa201030. amd specific, the laptop will load its own.
- **governor**: `powersave` on the `amd-pstate-epp` driver, epp hint `balance_performance`.
  this is the modern amd-pstate path, not the old laggy powersave, it boosts to full clocks
  on demand. left at the default, forcing `performance` only raises idle heat for no gain.
  gaming flips to `performance` per title through gamemode anyway.

## memory

- **swap**: none on disk. no hibernate, and disk swap would wear the nvme for little benefit
  at 32 GiB.

## storage

- **fstrim** (every host): weekly `fstrim.timer`, on by default in current nixos
  (`services.fstrim.enable`), nothing set in the repo. keeps the ssd's trim current.
- **io scheduler**: all three nvme drives run `[none]`, the kernel default and the right one
  for nvme. nothing to set.
- **root fs**: ext4, `relatime`. relatime already drops almost all atime writes, noatime
  would save a rounding error, skipped.

## gaming sysctls (desktop, gaming layer)

- **vm.max_map_count** = 2147483642 (`core/modules/specialized/gaming.nix`): some proton
  titles crash on the default mmap limit, this is the steamos/fedora value.

## gpu

nvidia tuning lives in `core/modules/specialized/nvidia.nix`, currently the stable branch (595.80).
latest (610) sits in the module as a commented package line.
610 adds dmabuf mmap on discrete gpus, the path the firefox flicker sits on, so swap it in to test the flicker once the build settles.
roll back at the boot menu if it regresses.

## evaluated and skipped

- **zen kernel**: not an upgrade in most cases now, default lts kept.
- **mitigations=off**: real cpu gain, security tradeoff not worth it on a daily machine.
- **systemd-oomd / earlyoom**: memory-pressure killers, not needed at 32 GiB with no swap, the kernel oom killer covers the rare runaway.
- **transparent hugepages tuning**: default `madvise` is already correct, nothing to do.
- **fwupd**: flashes device firmware (bios, ssd, peripherals) from lvfs. skipped, nothing here needs it. enable it if a firmware update is ever required.
