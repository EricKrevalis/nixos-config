-- popup that lists the keys that can follow a prefix, read from the desc on each keymap.

-- float the custom split keymaps to the top of the crowded <C-w> menu, ordered v, b, s, n,
-- plain keys before their ctrl-held forms.
-- matched by desc so the built-in window commands keep their default order below.
local split_order = { v = 1, b = 2, s = 3, n = 4 }
local function split_first(item)
  local d = item.desc or ""
  if not (d:find("^smart %(") or d:find("^vertical %(") or d:find("^horizontal %(")) then
    return "1"
  end
  -- raw_key is the untransformed key (e.g. <C-V>), item.key is replaced with a display glyph
  local raw = (item.raw_key or ""):lower()
  local mod = raw:match("^<c%-(.-)>$") -- ctrl form, captures the base letter
  local rank = split_order[mod or raw]
  if not rank then return "1" end
  return "0" .. (mod and "1" or "0") .. rank
end

return {
  "folke/which-key.nvim",
  event = "VeryLazy", -- load after startup, nothing needs it before the first keypress
  opts = {
    delay = 300, -- ms held on a prefix before the popup opens
    sort = { split_first, "local", "order", "group", "alphanum", "mod" },
    spec = {
      { "<leader>f", group = "find" },
      { "<leader>c", group = "code" },
      { "<C-w>",     group = "splits" },
    },
  },
}
