{ pkgs ? import <nixpkgs> { } }:
pkgs.mkShell {
  buildInputs = with pkgs; [
    # init.lua uses vim.lsp.config, which needs 0.11 or newer
    neovim
    # Language servers configured in init.lua
    gopls
    terraform-ls
    lua-language-server
    # Telescope shells out to these for live_grep and find_files
    ripgrep
    fd
    stylua
  ];

  shellHook = ''
    alias nvim="nvim -u $(pwd)/init.lua"
  '';
}
