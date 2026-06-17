{ config, lib, pkgs, ... }:

# dev tools layer on top of polish, enabled by host.dev
lib.mkIf config.host.dev {
  environment.systemPackages = with pkgs; [
    claude-code
    tree-sitter  # nvim-treesitter (main branch) calls `tree-sitter build` at runtime
    gcc
  ];
}
