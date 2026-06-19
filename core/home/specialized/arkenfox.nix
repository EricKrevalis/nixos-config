{ settings, lib, pkgs, ... }:

# arkenfox hardening layer, gated by settings.arkenfox
# firefox is always installed in home base, this only adds the hardened profile: user.js, ublock, theme
# the manual non-nix setup guide is the README in core/configs/firefox, alongside these files
let
  # ublock and theme are dropped into the profile, not pushed by policy, so there's no
  # "managed by your organization" and their settings stay mine to change. a profile install
  # checks signatures, so the signed amo xpis go in untouched, repacking would void them.
  ublock = pkgs.fetchurl {
    url = "https://addons.mozilla.org/firefox/downloads/file/4814095/ublock_origin-1.71.0.xpi";
    sha256 = "47f788a1fc2c014830b30bb0ef9588615701b98c5265fb19b8cf4ba779849feb";
  };
  ublockId = "uBlock0@raymondhill.net";
  theme = ../../configs/firefox/natural_forest_green-1.0.xpi; # amo file/3903186, v1.0
  themeId = "{054dd025-3fbd-45ab-a3d9-a22cecbbdd07}";

  # home-manager fills <profile>/extensions from each package's share/mozilla tree. firefox
  # keys that dir by its own app id, the xpi inside is named by the addon id.
  sideload = name: id: xpi: pkgs.runCommand name { } ''
    d="$out/share/mozilla/extensions/{ec8030f7-c20a-464f-9b0e-13a3a9e97384}"
    mkdir -p "$d"
    cp ${xpi} "$d/${id}.xpi"
  '';
in

lib.mkIf settings.arkenfox {
  # enable lives in home base, firefox is always installed, this only adds the profile
  programs.firefox = {
    profiles.arkenfox-tinkered = {
      isDefault = true;
      settings = {
        "browser.profiles.enabled" = false;   # off, ff's new profile db desyncs and flags the profile inaccessible
        "intl.locale.requested" = "en-US";    # built-in ui locale, no langpack install prompt
        "extensions.activeThemeID" = themeId; # select the forest green theme once it's installed
        "extensions.autoDisableScopes" = 0;   # auto-enable the profile-installed extensions, no approval prompt
      };
      # arkenfox base then my overrides, the same order arkenfox's own updater uses
      extraConfig = builtins.readFile ../../configs/firefox/user.js
                  + builtins.readFile ../../configs/firefox/user-overrides.js;
      # ublock's filters aren't seeded here, no nix-side mechanism does that without enforcing
      # them every launch. i import ublock-adminsettings.json once by hand, then they're mine.
      extensions.packages = [
        (sideload "ublock-origin" ublockId ublock)
        (sideload "natural-forest-green-theme" themeId theme)
      ];
      # force=true lets home-manager overwrite the search db firefox rewrites each launch.
      # hiding a builtin actually drops it, the settings ui only grays out its remove button.
      # no aliases on my engines, i don't want urlbar search shortcuts.
      search = {
        force = true;
        default = "qwant";
        privateDefault = "qwant";
        order = [ "qwant" "startpage" "mojeek" "ddg" "brave" ];
        engines = {
          startpage = {
            name = "Startpage";
            urls = [{ template = "https://www.startpage.com/sp/search?query={searchTerms}"; }];
            icon = "https://www.startpage.com/favicon.ico";
          };
          mojeek = {
            name = "Mojeek";
            urls = [{ template = "https://www.mojeek.com/search?q={searchTerms}"; }];
            icon = "https://www.mojeek.com/favicon.ico";
          };
          brave = {
            name = "Brave Search";
            urls = [{ template = "https://search.brave.com/search?q={searchTerms}"; }];
            icon = "https://search.brave.com/favicon.ico";
          };
          google.metaData.hidden = true;
          bing.metaData.hidden = true;
          ebay.metaData.hidden = true;
          "amazondotcom-us".metaData.hidden = true;
          wikipedia.metaData.hidden = true;
          ecosia.metaData.hidden = true;	# morally nice, but not privacy focused
          qwant.metaData.hidden = false;	# privacy focused EU. ES region bound
          perplexity.metaData.hidden = true;
        };
      };
    };
  };
}
