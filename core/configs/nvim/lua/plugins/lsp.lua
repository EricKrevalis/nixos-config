-- language servers: enable them, set keymaps, tune diagnostics.
-- the server binaries come from nix, nvim-lspconfig only supplies the launch defaults.
return {
  "neovim/nvim-lspconfig",
  event = { "BufReadPre", "BufNewFile" },
  dependencies = { "saghen/blink.cmp" }, -- load blink first so we can hand its capabilities to the servers
  config = function()
    -- every server's root markers, specific first, .git the last resort.
    local root_markers = {
      "flake.nix",
      "pyrightconfig.json", "pyproject.toml", "setup.py", "setup.cfg", "requirements.txt", "Pipfile",
      "ruff.toml", ".ruff.toml",
      ".luarc.json", ".luarc.jsonc", ".emmyrc.json", ".luacheckrc",
      "stylua.toml", ".stylua.toml", "selene.toml", "selene.yml",
      ".marksman.toml",
      ".git",
    }

    -- blink's lsp capabilities for every server.
    -- function root_dir overrides root_markers, hence the manual marker search below.
    -- the dir fallback lets lua_ls and marksman work on files outside a project.
    vim.lsp.config("*", {
      capabilities = require("blink.cmp").get_lsp_capabilities(),
      root_dir = function(bufnr, on_dir)
        local fname = vim.api.nvim_buf_get_name(bufnr)
        on_dir(vim.fs.root(bufnr, root_markers) or (fname ~= "" and vim.fs.dirname(fname)) or vim.fn.getcwd())
      end,
    })

    -- ruff does lint and format only, basedpyright owns hover and types.
    -- pin ruff to basedpyright's utf-16 so the two agree on positions, and drop ruff's hover.
    vim.lsp.config("ruff", {
      capabilities = { general = { positionEncodings = { "utf-16" } } },
      on_attach = function(client)
        client.server_capabilities.hoverProvider = false
      end,
    })

    -- turn on the servers, defaults from nvim-lspconfig, binaries from the nix dev layer.
    vim.lsp.enable({
      "nixd",         -- nix
      "lua_ls",       -- lua
      "bashls",       -- bash
      "basedpyright", -- python types, completion, navigation
      "ruff",         -- python lint and format
      "marksman",     -- markdown
    })

    -- calm diagnostics: signs in the gutter, message on demand, nothing inline or while typing.
    vim.diagnostic.config({
      virtual_text = false,
      signs = true,
      underline = true,
      update_in_insert = false,
      severity_sort = true,
      float = { border = "rounded", source = true },
    })

    -- buffer-local keys, set only once a server attaches.
    -- rename/refs/actions/hover are neovim 0.11 defaults (grn gra grr K), add only what's missing.
    vim.api.nvim_create_autocmd("LspAttach", {
      callback = function(ev)
        local function map(keys, fn, desc)
          vim.keymap.set("n", keys, fn, { buffer = ev.buf, desc = desc })
        end
        map("gd", vim.lsp.buf.definition, "definition")
        map("gD", vim.lsp.buf.declaration, "declaration")
        map("<leader>e", vim.diagnostic.open_float, "line diagnostics")
      end,
    })
  end,
}
