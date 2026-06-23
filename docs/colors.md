# colors

every color the config sets by hand, what it does, and exactly where it lives. written before moving theming to stylix so the hand-tuned work isn't lost: stylix drives everything from one base16 palette, this is the record of what i had so i can rebuild it as overrides or seed the palette from it.

the look is a warm forest scheme, not one tight palette: forest green plus burnt orange plus brown, dark backgrounds. the accent shifts per surface (sway borders brown, waybar accent orange, starship green/orange), so a base16 mapping has to spread these across the accent slots rather than collapse them to one.

## palette

| hex | rough name | where |
| --- | --- | --- |
| #6A5535 | brown | sway focused border |
| #3A2210 | dark brown | sway unfocused border |
| #cc3333 | red | sway urgent border |
| #ffffff | white | sway focused/urgent text |
| #888888 | grey | sway unfocused text |
| #d4783a | orange | waybar primary accent (text, clock, focused workspace, connectivity icons) |
| #AA6A42 | brown-orange | waybar workspace hover text |
| #7d9470 | sage | waybar pill border, hover background |
| #a8b898 | pale green | waybar idle workspace dots |
| #6b8a62 | muted green | waybar persistent workspace dots |
| #9aaa88 | grey-green | waybar muted/disconnected icons |
| #0f2910 | dark green | waybar pill background (at 80%) |
| #346b30 | forest green | starship prompt, success |
| #bc4e20 | burnt orange | starship prompt, error |
| #585858 #6b6b6b #999999 | lifted greys | computer icon overlay |

## sway window borders

core/home/base.nix, the `colors` block (around line 515). focused windows get the brown, everything dim gets the dark brown, urgent gets red. text is white on the active surfaces, grey on the dim ones.

```nix
colors = {
  focused = {
    border = "#6A5535"; background = "#6A5535"; text = "#ffffff";
    indicator = "#6A5535"; childBorder = "#6A5535";
  };
  unfocused = {
    border = "#3A2210"; background = "#3A2210"; text = "#888888";
    indicator = "#3A2210"; childBorder = "#3A2210";
  };
  focusedInactive = { # same as unfocused
    border = "#3A2210"; background = "#3A2210"; text = "#888888";
    indicator = "#3A2210"; childBorder = "#3A2210";
  };
  urgent = {
    border = "#cc3333"; background = "#cc3333"; text = "#ffffff";
    indicator = "#cc3333"; childBorder = "#cc3333";
  };
};
```

## waybar

core/configs/waybar/style.css. transparent bar, each module a rounded pill: dark green translucent fill, sage border. orange is the running accent (default text, clock, focused workspace, the audio/bt/net icons), greens carry the workspace states, grey-green marks muted or disconnected.

- bar text default: `color: #d4783a` (line 11)
- pill background: `background: rgba(15, 41, 16, 0.8)` (#0f2910 at 80%, line 19)
- pill border: `border: 1px solid #7d9470` (line 20)
- clock text: `color: #d4783a` (line 28)
- workspace dot idle: `color: #a8b898` (line 35)
- workspace dot focused: `color: #d4783a` (line 41)
- workspace dot persistent: `color: #6b8a62` (line 47)
- workspace hover background: `background: rgba(125, 148, 112, 0.35)` (#7d9470 at 35%, line 52)
- workspace hover text: `color: #AA6A42` (line 54)
- audio/bluetooth/network icons: `color: #d4783a` (line 72)
- muted/disconnected icons: `color: #9aaa88` (lines 76, 81)

## starship prompt

core/home/base.nix, the starship `character` settings (around line 121). the » arrow turns forest green after a command succeeds, burnt orange after one fails.

```nix
character = {
  success_symbol = "[»](#346b30)";
  error_symbol = "[»](#bc4e20)";
};
```

## computer icon overlay

core/home/base.nix, the inline `computer.svg` (around line 7). papirus-dark reuses its light computer glyph, too dark on this desktop, so i lifted three greys to make it read. greys, not part of the accent scheme, but a deliberate edit.

- body `#333333` -> `#585858`
- edge `#595959` -> `#6b6b6b`
- screen `#8e8e8e` -> `#999999`
- plus white highlights at 0.1 / 0.2 opacity

## firefox theme

core/home/specialized/arkenfox.nix (line 14). a sideloaded amo theme, "natural forest green" 1.0, not a hex set i control. the colors live inside the xpi, listed here so the green firefox chrome isn't forgotten when matching the rest.

## swaylock

core/home/base.nix, `programs.swaylock.settings`. only the background is set, `color = "0f2910"` (the same dark green as the waybar pill, no leading #). the indicator ring keeps swaylock's defaults for now, radius 90 and thickness 8 are sizes not colors.

## power menu (gum)

core/home/base.nix, the `powermenu` script. gum draws the list, the highlight cursor is set to the orange accent, `--cursor.foreground "#d4783a"`. everything else stays gum's default.

## not colors (so they don't get grepped in by mistake)

- core/modules/specialized/gaming.nix line 10: `nixpkgs#351516` is a github issue reference.
- core/home/specialized/gaming.nix: mangohud `background_alpha = 0.25` is opacity.
- mako (core/home/base.nix) sets only `border-radius`, no colors yet, it still uses mako's default palette.
- alacritty and fuzzel set no colors, both fall back to their built-in defaults (fuzzel's default is light, the one mismatch).
