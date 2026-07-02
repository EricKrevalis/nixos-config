{ config, settings, lib, pkgs, ... }:

# home-side dev tooling, gated like core/modules/specialized/dev.nix.
lib.mkIf settings.dev {

  # claude-code fullscreen (alternate-screen) renderer, the declarative equivalent of /tui fullscreen
  home.sessionVariables.CLAUDE_CODE_NO_FLICKER = "1";

  # neovim config, symlinked to the live repo dir not a store copy, so lua edits are instant
  # and lazy writes lazy-lock.json straight into the repo. neovim itself comes from base.
  xdg.configFile."nvim".source =
    config.lib.file.mkOutOfStoreSymlink
      "${config.home.homeDirectory}/.config/nixos/core/configs/nvim";

  # treesitter grammars and queries for neovim, both from one nvim-treesitter package.
  # mismatched sources let a query reference a node the parser lacks (the except* skew).
  # no compiler here, grammars are prebuilt; symlinkJoin merges the per-lang .so into one dir.
  xdg.dataFile."nvim/treesitter/parser".source =
    "${pkgs.symlinkJoin {
      name = "nvim-treesitter-grammars";
      paths = with pkgs.vimPlugins.nvim-treesitter.grammarPlugins; [
        # edited languages
        nix
        lua
        bash
        python
        markdown
        markdown_inline # markdown is two grammars, this one does inline marks and fenced code
        # support grammars
        vimdoc # colors neovim :help pages
        query # colors treesitter .scm files
      ];
    }}/parser";

  # the matching queries, from the same package as the grammars above.
  xdg.dataFile."nvim/treesitter/queries".source =
    "${pkgs.vimPlugins.nvim-treesitter}/runtime/queries";

  # tooling for neovim, binaries only, the lua wiring is in the nvim config.
  home.packages = with pkgs; [
    # language servers
    nixd                 # nix
    lua-language-server  # lua
    bash-language-server # bash
    basedpyright         # python types, completion, navigation
    ruff                 # python lint and format
    marksman             # markdown
    # formatters
    nixfmt               # nix, official rfc style
    stylua               # lua
    shfmt                # bash
  ];

  # fuzzy finder. fd backs the file/dir widgets so Ctrl+T and Alt+C honor .gitignore and skip hidden files.
  programs.fzf = {
    enable = true;
    enableZshIntegration = true;
    defaultCommand = "fd --type f";
    fileWidgetCommand = "fd --type f";
    changeDirWidgetCommand = "fd --type d";
    defaultOptions = [ "--height 40%" "--layout reverse" "--border" ];
  };

  # delta wires into git as the diff pager, so it belongs here, not in systemPackages.
  programs.delta = {
    enable = true;
    enableGitIntegration = true;
    options = {
      navigate = true;     # n and N jump between diff sections
      line-numbers = true;
    };
  };

  # delta as lazygit's pager. pagers array, not the old paging object (0.62+)
  programs.lazygit = {
    enable = true;
    settings = {
      os.editPreset = "nvim";
      git.pagers = [
        {
          colorArg = "always";
          pager = "delta --paging=never";
        }
      ];
    };
  };
}
