# nixos-config

my nixos setup for `desktop` (and later `laptop`). flake based, home manager runs as a
nixos module. one settings block per host, the rest is shared modules layered in tiers.

## rebuilding

```bash
sudo nixos-rebuild switch
```

uses the flake through the `/etc/nixos/flake.nix` symlink and picks the config matching my
hostname. see `docs/bootstrap.md` for how that link is set up and how to recreate it on a
fresh install.

## how it fits together

every host is one call to `mkHost` in `flake.nix`. it takes a `settings` attrset (`common`
merged with per-host overrides) and threads it into every module. so the whole surface for
a machine is that one block:

```nix
desktop = mkHost (common // {
  hostname    = "desktop";
  nvidia      = true;   # proprietary nvidia stack
  extended    = true;   # feature complete desktop
  specialized = true;   # dev and gaming on top
});
```

those booleans are typed in `modules/options.nix`, so a wrong value is a build error, not a
silent no-op. the software stacks in tiers, each one opt in per host:

- basic       every host, base system plus sway. `modules/basic.nix`
- extended    feature complete desktop for normal use. `modules/extended.nix`
- specialized dev and gaming on top of extended. `modules/specialized.nix`

nvidia is a separate hardware toggle (`modules/nvidia.nix`), inert unless `nvidia = true`.
non nvidia machines run the default mesa stack and set nothing.

## layout

```
flake.nix / flake.lock   inputs, the common settings block, one mkHost per machine
modules/                 shared modules: basic, extended, specialized, nvidia, options
home/basic.nix           home manager base (git, zsh, sway), shared by every host
hosts/<host>/            per machine: hardware-configuration.nix, configuration.nix, home.nix
template/                self contained starter others can fork (see below)
scripts/sync-template.sh keeps template/ in step with the modules
docs/                    my own notes, not read by nix
configs/                 raw config files, wired in from home (see conventions)
```

## using this on your own machine

scaffold your own config from mine:

```bash
nix flake init -t github:EricKrevalis/nixos-config
```

that copies the `template/` starter into an empty dir, just the engine, none of my hosts.
then:

1. edit `flake.nix` `common` with your name, email, timezone, hostname
2. flip the toggles you want (`nvidia`, `extended`, `specialized`)
3. generate your hardware config:
   ```bash
   sudo nixos-generate-config --show-hardware-config > hosts/nixos/hardware-configuration.nix
   ```
4. `sudo nixos-rebuild switch --flake .#nixos`

the build fails until step 3 is done, that is on purpose. nixos will not build a system
with no root filesystem, so you cannot switch into a generation that will not boot.

rebuilding one of my actual machines straight from github, no clone needed:

```bash
sudo nixos-rebuild switch --flake github:EricKrevalis/nixos-config#desktop
```

## conventions

anything that changes the system goes through nix, so the file in the repo is the live one.
no hand editing the running copy.

- config files: keep the real file in `configs/`, point at it from home:
  ```nix
  xdg.configFile."waybar/config".source = ./configs/waybar/config;
  ```
- scripts: keep them in `scripts/`, package them onto PATH:
  ```nix
  environment.systemPackages = [
    (pkgs.writeShellScriptBin "name" (builtins.readFile ./scripts/name.sh))
  ];
  ```
- `docs/` is just notes for me, nothing there affects the build

## template sync

`template/` is a self contained copy of the engine so a fork starts clean, without my hosts.
the module files in it are generated, not hand edited. after changing a module, mirror it:

```bash
./scripts/sync-template.sh          # copy modules into template/
./scripts/sync-template.sh --check  # fail if they have drifted
```

two guards run the check so the template can never quietly fall out of sync:

- a pre commit hook in `.githooks/`, enable once per clone with
  `git config core.hooksPath .githooks`
- github actions on every push (`.github/workflows/check.yml`), which also evaluates both
  flakes
