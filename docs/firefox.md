# firefox

my firefox is arkenfox-hardened and fully declarative. home-manager owns it and the profile
gets rebuilt from the repo every time, so i can wipe ~/.config/mozilla, run `nrs`, and it comes
back exactly the same. none of what's in the repo is sensitive (it's prefs and uBlock filter
settings, no passwords or cookies, those never lived here), so it can sit in a public repo fine.

how it splits: firefox is installed on every host and is the default browser, set in home base.
no enterprise policy anywhere, base is just firefox.enable, so firefox never says "managed by
your organization". the arkenfox hardening sits in
core/home/specialized/arkenfox.nix, gated by the `arkenfox` toggle (off by default), so a fork
gets a plain firefox and opts into my hardened profile only if it flips the toggle.
mullvad-browser is still installed too, the extra hardened-browsing option, just no longer the
default.

## where the bits live

- `core/configs/firefox/user.js`, the arkenfox base, straight from their repo. i don't touch
  this by hand, `updater.sh` refreshes it (see bumping arkenfox below).
- `core/configs/firefox/user-overrides.js`, my prefs on top (quad9 dns, forcing gpu compositing,
  killing urlbar suggestions, ai off, clear-on-close). this is the file i actually edit for prefs.
- `core/configs/firefox/updater.sh`, arkenfox's own updater, vendored. only used to bump user.js.
- `core/configs/firefox/ublock-adminsettings.json`, my uBlock config, exported from the dashboard.
- `core/configs/firefox/natural_forest_green-1.0.xpi`, the theme. vendored because it's an obscure
  addon that could vanish from amo. uBlock isn't vendored, it's huge and never going away, so i
  pull it by hash instead. both go into the profile as the signed amo xpi untouched, a profile
  install checks signatures so i can't repack them.
- `core/home/specialized/arkenfox.nix`, where it's all wired up: the `programs.firefox` block
  with the profile, the prefs i let nix manage, and uBlock + the theme dropped into the profile
  via `extensions.packages`. gated by the `arkenfox` toggle. firefox's own enable and the
  default-browser default live in `core/home/base.nix`, every host gets those.
- `core/configs/firefox/README.md`, the by-hand setup guide for a non-nix box, see handing it to a
  friend below. it sits with the files it documents, so a fork gets it too.

## why it's built this way

home-manager owns firefox instead of the system because only home-manager writes a per-profile
user.js. firefox 147+ uses ~/.config/mozilla (the xdg path) when ~/.mozilla doesn't exist, so
that's where the profile lands now. the "profile cannot be loaded, may be missing or
inaccessible" warning that dogged me for weeks came from firefox's new sqlite profile database
(the StoreID) disagreeing with a hand-copied profile. `browser.profiles.enabled = false` keeps
that whole new profile-db out of the picture, so the mismatch can't happen.

extensions go in through the profile, not policy: home-manager drops the pinned signed xpis into
the profile's extensions dir and `extensions.autoDisableScopes = 0` enables them with no prompt.
i moved off policy because force-install showed the "managed by your organization" banner and,
worse, the managed-storage key it carried re-applied uBlock's config on every launch and wiped
whatever i changed in the browser. now uBlock's config is mine: i import ublock-adminsettings.json
once and it sticks. the cost is a fresh profile starts on uBlock's defaults until i do that import.

locale is pinned to en-US so firefox stops nagging me to install the en-CA/en-GB language packs.

## turning it on in a fork

the hardening is a toggle now, so a fork doesn't copy anything, it flips `arkenfox = true` in its
flake common (or per host) and gets my profile. to make it theirs:

- swap `core/configs/firefox/user-overrides.js` for your own prefs. keep the arkenfox base or
  refresh it, your call.
- replace `ublock-adminsettings.json` with your own (uBlock dashboard, backup to file, drop the
  timeStamp line).
- the extension ids and the pinned uBlock url/hash are mine, change them in
  `core/home/specialized/arkenfox.nix`.

firefox is the default browser whether or not arkenfox is on, a host can point web at a different
browser in its own home file if it wants.

## handing it to a non-nix friend

the nix setup assembles the profile (writes user.js, installs the extensions, sets the search
engines), none of which happens on a normal linux box. there's no policy to lean on anymore, so
this is a manual checklist, not a generated bundle. `core/configs/firefox/README.md` walks each piece:
copy user.js + user-overrides.js + updater.sh and run `./updater.sh -d` for the prefs, install
uBlock from amo and import my ublock-adminsettings.json, install the theme from file, add the
search engines by url. the source files all live in `core/configs/firefox`, so nothing is
duplicated and there's nothing to keep in sync.

## changing my settings later (note to self)

prefs are the repo's job, the browser rebuilds them from it and a live tweak won't survive a wipe.
extensions and uBlock's config are different now: nix installs the extension but its state lives
in the profile and is mine, so i change uBlock in the browser and it just sticks, no nrs, no
export. by case:

uBlock filters or rules:
- change it in the uBlock dashboard, it persists on its own, nothing else to do.
- `ublock-adminsettings.json` in the repo is only the seed a fresh profile imports by hand. it
  does not auto-apply, so it can lag what i'm running. when i want the fresh-profile baseline to
  match, backup to file from the dashboard, drop the export over the json, delete the timeStamp
  line. that refreshes the seed, the live browser already had the change.

arkenfox or firefox prefs:
- my own prefs (a `user_pref` line) live in `user-overrides.js`. that's the file for prefs.
- a few prefs i hand to nix directly (locale, theme, the profile-db toggle) are in the
  `programs.firefox` block in `core/home/specialized/arkenfox.nix`, in `profiles.<name>.settings`.
- bumping arkenfox: `cd core/configs/firefox && ./updater.sh -n -d`. it pulls the latest arkenfox
  user.js over `user.js`. `-n` keeps it pristine (no overrides merged in, they stay their own
  file), `-d` skips the script self-update prompt. review `git diff user.js`, then `nrs`. don't
  run the updater against the live profile, nix owns that copy and would just overwrite it.

search engines, extensions:
- these aren't prefs, they live in binary/sqlite so they can't go in user.js. search engines are
  the `search.engines` block in `core/home/specialized/arkenfox.nix` (the engine list and the
  hidden builtins), extensions are the `extensions.packages` list in the same block. cookie
  keep-logged-in exceptions aren't managed anymore, that needed policy, i set them in the browser
  and they persist.

extensions:
- new uBlock version, grab the url and hash from the amo api
  (`https://addons.mozilla.org/api/v5/addons/addon/ublock-origin/`, fields current_version.file
  .url and .hash) and update the fetchurl in `core/home/specialized/arkenfox.nix`.
- new addon, add its signed amo xpi to `extensions.packages` with its id (pin by hash like uBlock,
  or vendor the xpi into `core/configs/firefox/` if it's niche). must be the signed xpi, a profile
  install checks signatures, a repack would void them.

start from scratch:
- `rm -rf ~/.config/mozilla ~/.cache/mozilla`, then `nrs`. prefs, ublock and the theme come back
  on their own, then i import ublock-adminsettings.json once for the filters.
- gotcha: if nothing else in the config changed, home-manager's activation unit doesn't re-run on
  that `nrs`, so a bare wipe-then-rebuild can come back empty. any real config change repopulates
  it fine. a new machine always rebuilds clean.
