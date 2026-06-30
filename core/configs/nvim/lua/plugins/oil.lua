-- file manager as an editable buffer. edit a dir like text, :w applies the changes.
return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" }, -- file type icons, needs a nerd font
  lazy = false, -- load at startup so oil can take over directory editing from netrw
  opts = {
    default_file_explorer = true, -- opening a dir opens oil, not netrw
    view_options = {
      show_hidden = true, -- show dotfiles
    },
    keymaps = {
      ["q"] = "actions.close", -- quit oil back to the previous buffer
    },
  },
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "open parent dir (oil)" },
  },
}
