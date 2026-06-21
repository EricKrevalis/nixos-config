// personal overrides on top of the arkenfox base above. arkenfox's own model:
// user.js is upstream, this file is mine, both get concatenated into the profile.

// dns: quad9 over https, mode 3 so there's no fallback to the system resolver
user_pref("network.trr.mode", 3);
user_pref("network.trr.uri", "https://dns.quad9.net/dns-query");
user_pref("network.trr.custom_uri", "https://dns.quad9.net/dns-query");

// firefox's "never remember history" secretly flips on permanent private browsing.
// arkenfox already clears history/cache/cookies per category, so keep autostart off.
user_pref("browser.privatebrowsing.autostart", false);

// land on about:newtab at launch so the bookmarks toolbar shows.
// arkenfox's blanktab default doesn't trigger it.
user_pref("browser.startup.page", 1);
user_pref("browser.startup.homepage", "about:newtab");

// force gpu compositing on. firefox blocklists it on the nvidia proprietary driver
// user_pref("layers.acceleration.disabled", false);
user_pref("gfx.webrender.all", true);

// no address bar suggestions of any kind
user_pref("browser.urlbar.suggest.bookmark", false);
user_pref("browser.urlbar.suggest.history", false);
user_pref("browser.urlbar.suggest.openpage", false);
user_pref("browser.urlbar.suggest.engines", false);
user_pref("browser.urlbar.suggest.topsites", false);
user_pref("browser.urlbar.suggest.recentsearches", false);

// firefox ai/ml features, all off
user_pref("browser.ai.control.default", "blocked");
user_pref("browser.ai.control.linkPreviewKeyPoints", "blocked");
user_pref("browser.ai.control.pdfjsAltText", "blocked");
user_pref("browser.ai.control.sidebarChatbot", "blocked");
user_pref("browser.ai.control.smartTabGroups", "blocked");
user_pref("browser.ai.control.smartWindow", "blocked");
user_pref("browser.ai.control.translations", "blocked");
user_pref("browser.ml.chat.enabled", false);
user_pref("browser.ml.chat.page", false);
user_pref("browser.ml.linkPreview.enabled", false);
user_pref("extensions.ml.enabled", false);
user_pref("pdfjs.enableAltText", false);

// translations off entirely
user_pref("browser.translations.enable", false);
user_pref("browser.translations.automaticallyPopup", false);

// new tab page: no shortcuts, highlights, search box or weather
user_pref("browser.newtabpage.activity-stream.feeds.topsites", false);
user_pref("browser.newtabpage.activity-stream.showSearch", false);
user_pref("browser.newtabpage.activity-stream.system.showWeatherOptIn", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includeBookmarks", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includeDownloads", false);
user_pref("browser.newtabpage.activity-stream.section.highlights.includeVisited", false);

// urlbar: no shortcut buttons, no quick actions or quick suggest
user_pref("browser.urlbar.shortcuts.actions", false);
user_pref("browser.urlbar.shortcuts.bookmarks", false);
user_pref("browser.urlbar.shortcuts.history", false);
user_pref("browser.urlbar.shortcuts.tabs", false);
user_pref("browser.urlbar.suggest.quickactions", false);
user_pref("browser.urlbar.suggest.quicksuggest.all", false);

// passwords: no save prompt, no generated passwords, no relay or breach alerts.
// arkenfox leaves rememberSignons at its default (on)
user_pref("signon.rememberSignons", false);
user_pref("signon.generation.enabled", false);
user_pref("signon.firefoxRelay.feature", "disabled");
user_pref("signon.management.page.breach-alerts.enabled", false);

// form autofill: never save or fill payment cards or addresses
user_pref("extensions.formautofill.creditCards.enabled", false);
user_pref("extensions.formautofill.addresses.enabled", false);

// the "smart" (ai) tab grouping and hover thumbnails off
user_pref("browser.tabs.groups.smart.enabled", false);
user_pref("browser.tabs.groups.smart.userEnabled", false);
user_pref("browser.tabs.dragDrop.createGroup.enabled", false);
user_pref("browser.tabs.hoverPreview.showThumbnails", false);

// retire the mouse selection path: no highlight-to-primary copy, no middle-click paste
user_pref("clipboard.autocopy", false);
user_pref("middlemouse.paste", false);

// misc ui: spellcheck off, no picture-in-picture toggle, manual performance settings
user_pref("layout.spellcheckDefault", 0);
user_pref("media.videocontrols.picture-in-picture.video-toggle.enabled", false);
user_pref("browser.preferences.defaultPerformanceSettings.enabled", false);

// privacy bits beyond arkenfox
user_pref("privacy.trackingprotection.emailtracking.enabled", true);
user_pref("privacy.annotate_channels.strict_list.enabled", true);
user_pref("privacy.query_stripping.enabled.pbmode", true);
user_pref("network.lna.blocking", true);
user_pref("browser.search.serpEventTelemetryCategorization.regionEnabled", false);

// pin the search region instead of letting geo-ip decide. deterministic
user_pref("browser.search.region", "ES");

// the daily usage ping arkenfox doesn't cover, separate from the healthreport it does
user_pref("datareporting.usage.uploadEnabled", false);

// nimbus feature rollouts, ff148 split this into its own data-use setting arkenfox doesn't cover
user_pref("nimbus.rollouts.enabled", false);

// uniform opt-out header, not a fingerprint, carries ccpa/gdpr weight
user_pref("privacy.globalprivacycontrol.enabled", true);

// disables Restore Previous Session, so I turn it off, don't want to lose tabs I forgot about
user_pref("privacy.clearOnShutdown_v2.browsingHistoryAndDownloads", false);
// exceptions don't get their settings removed, so we keep this on
user_pref("privacy.clearOnShutdown_v2.siteSettings", true);
// on a fresh profile firefox migrates the old clearOnShutdown, so we need to set these flags
user_pref("privacy.sanitize.clearOnShutdown.hasMigratedToNewPrefs3", true);
user_pref("privacy.sanitize.cpd.hasMigratedToNewPrefs3", true);

// enhanced tracking protection on strict
user_pref("browser.contentblocking.category", "strict");
// if enabled, we get more tracking. if disabled, we get less functional websites. 
user_pref("privacy.trackingprotection.allow_list.hasMigratedCategoryPrefs", false);

// downloads: always ask where to save, prompt before opening unknown types
user_pref("browser.download.useDownloadDir", false);
user_pref("browser.download.always_ask_before_handling_new_types", true);

// appearance: dark firefox ui, dark websites, tabs drawn in the titlebar
user_pref("browser.theme.toolbar-theme", 0);
user_pref("layout.css.prefers-color-scheme.content-override", 0);
user_pref("browser.tabs.inTitlebar", 1);

// my toolbar layout: home + ublock + private-window-reset buttons, bookmarks bar shown
user_pref("browser.uiCustomization.state", "{\"placements\":{\"widget-overflow-fixed-list\":[],\"unified-extensions-area\":[],\"nav-bar\":[\"back-button\",\"forward-button\",\"stop-reload-button\",\"home-button\",\"customizableui-special-spring1\",\"vertical-spacer\",\"urlbar-container\",\"customizableui-special-spring2\",\"downloads-button\",\"fxa-toolbar-menu-button\",\"unified-extensions-button\",\"ublock0_raymondhill_net-browser-action\",\"reset-pbm-toolbar-button\"],\"toolbar-menubar\":[\"menubar-items\"],\"TabsToolbar\":[\"firefox-view-button\",\"tabbrowser-tabs\",\"new-tab-button\",\"alltabs-button\"],\"vertical-tabs\":[],\"PersonalToolbar\":[\"personal-bookmarks\"]},\"seen\":[\"developer-button\",\"screenshot-button\",\"ublock0_raymondhill_net-browser-action\",\"reset-pbm-toolbar-button\"],\"dirtyAreaCache\":[\"nav-bar\",\"vertical-tabs\",\"toolbar-menubar\",\"TabsToolbar\",\"PersonalToolbar\"],\"currentVersion\":24,\"newElementCount\":2}");
