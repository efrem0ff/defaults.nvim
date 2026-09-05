{ pkgs ? import <nixpkgs> {
    overlays = [
      (import (builtins.fetchTarball {
        url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
      }))
    ];
  }
}:
with pkgs;
mkShell {
  buildInputs = [
    neovim-nightly
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
