### Introduction

A personal neovim configuration that is:

* Small (~ 400 lines)
* Single-file
* Documented

Forked from [mjlbach/defaults.nvim](https://github.com/mjlbach/defaults.nvim), which is a starting template meant to be read through and modified. This copy has been modified, so it is no longer that template. It is opinionated: default keymaps, a few utility functions, and only the language servers its author uses.

The pieces you would most likely want to change:

* Language servers -- gopls, terraform-ls and lua-language-server are enabled, nothing else
* Completion       -- blink.cmp, configured to keep the ranking the server sends in each item's sortText
* Key bindings     -- roughly 39 of them, set by default so the configuration is usable as-is
* Utility functions -- a toggle that turns off mouse, signs, numbers and indent guides together, and a prompted directory grep

None of them appreciably impact startup time.

See the upstream [wiki](https://github.com/mjlbach/defaults.nvim/wiki) for additional tips, tricks, and recommended plugins.

### Formatting

```bash
$ make deps   # brew install stylua lua-language-server
$ make fmt    # stylua init.lua
```

### Running via nix (optional)

Nix is a purely functional package manager, that affords reproducibility similar to a container (albeit with a very different mechanism). This repo bundles a nix-shell, which includes the latest version of neovim along with the language servers listed above and the tools telescope shells out to (ripgrep, fd). This is entirely optional, and is just a convenient way to install and manage them.

1. Install nix
```bash
$ sh <(curl -L https://nixos.org/nix/install) --daemon
```

2. Clone this repository:
```bash
$ git clone https://github.com/efrem0ff/defaults.nvim.git && cd defaults.nvim
```

3. Start the shell
```bash
$ nix-shell
$ nix develop # if on nixUnstable
```
