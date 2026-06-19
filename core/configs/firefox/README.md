# hardened firefox, by hand

the non-nix way to set up this firefox: arkenfox prefs, ublock with my filters, the theme, the
search engines. on a nixos machine the arkenfox module does all of this declaratively, a plain
firefox on any other box has none of it, so this is the manual checklist. the files it refers to
sit right here in this folder.

no enterprise policy anywhere, so nothing here makes firefox say "managed by your organization"
and every setting stays yours to change.

## prefs (arkenfox)

1. open about:profiles, note the profile's root folder, quit firefox
2. copy user.js, user-overrides.js and updater.sh into that folder
3. from there run `./updater.sh -d`, this merges the overrides onto the arkenfox base.
   skip it and you get arkenfox's base but none of my prefs
4. start firefox

later, rerun `./updater.sh -d` to pull the latest arkenfox and reapply the overrides.

## ublock

1. install ublock origin from addons.mozilla.org
2. dashboard, settings tab, restore from file, pick ublock-adminsettings.json. brings in the
   filter lists and rules in one go
3. optional: about:addons, ublock, run in private windows, if you want it there too

after the import the config is yours, change anything and it sticks.

## theme

about:addons, gear icon, install add-on from file, pick natural_forest_green-1.0.xpi. purely
cosmetic, skip it if you like.

## search engines

settings, search. firefox has no clean way to seed engines from a file, so add them by hand. the
add-engine field wants `%s` where the query goes:

- Qwant       `https://www.qwant.com/?q=%s`
- Startpage   `https://www.startpage.com/sp/search?query=%s`
- Mojeek      `https://www.mojeek.com/search?q=%s`
- DuckDuckGo  `https://duckduckgo.com/?q=%s`
- Brave       `https://search.brave.com/search?q=%s`

make qwant the default (private windows too) and order them qwant, startpage, mojeek, duckduckgo,
brave. qwant and duckduckgo ship with firefox, qwant only shows in the EU region so add it by url
if it's missing. remove google, bing, amazon, ebay, wikipedia, ecosia and perplexity.

## bookmark

if you want it, add privacyguides.org/en/tools to the bookmarks toolbar by hand. i don't seed it,
one bookmark isn't worth firefox re-importing it on every launch.
