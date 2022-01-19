
# Welcome to doom-evim
This project has been inspired by doom-emacs and doom-nvim. However, I named it doom because it is batteries-included like doom-nvim and doom-emacs.Why the 'e'? To pay a homage to emacs' revered emacs-lisp.

## Introduction
doom-evim does not have all the configurations that will cater all the users of this repo but it will provide the default configurations necessary to quickly bolt-on to this distribution's features. For example, in order to add a server to nvim-lsp using the default configuration at nvim-lspconfig's repo, you can simply append to doom.lsp.servers with your required configuration or a blank table. 

This distribution is **EXTREMELY OPINIONATED**. I use lua, ruby and python and henceI configured it for that. However, you can easily add your setups and I might include them if they are stable and work for everybody.

## Features
1. Fennel support for those who really miss elisp!
2. A combination of fennel and lua configurations also supported. 
3. LSP servers can be added with default or custom configurations. 
4. LSP keybindings are automatically set. Also nvim-cmp is configured with luasnip.
5. Telescope integration built-in.
6. A wider range of colorschemes.
7. Nice default keymappings for doom-emacs users. (However, not exactly like doom-emacs)
8. Which-key integration.
9. Nice configurations for ruby, lua and python included.
10. A basic REPL built-in that is easy to use and configure.
    - Supports all basic operations: Send line, till-point, buffer to REPL.
    - Automatically split and debug current buffer according to its filetype.
11. Features that rival emacs': 
    - An emacs-equivalent (and in some ways, stronger) hooking utility: `add-hook`.
    - An emacs-equivaluent (and in some ways, stronger) keybinding utility: `define-key[s]`.
    - A nice doom-like `after!` to configure packages.
    - A bunch of handy functions that you can use. 

## Installation
### Basic requirements
1. [neovim >= 0.5](https://github.com/neovim/neovim/wiki/Installing-Neovim)
2. `fdfind` and `rg`. You OS package manager should have these. 
3. lua5.1 modules: [rex_pcre2](https://rrthomas.github.io/lrexlib/manual.html), [luafun](https://luafun.github.io/), [lualogging](https://neopallium.github.io/lualogging/index.html), [lpath](https://github.com/starwing/lpath) and [lua-set](https://github.com/EvandroLG/set-lua).
4. GNU/Linux. Currently doom-evim only supports GNU/Linux.

### Other requirements
1. [NF Ubuntu Mono](https://github.com/ryanoasis/nerd-fonts/tree/master/patched-fonts/UbuntuMono)
2. [REPL for fennel](https://github.com/Olical/conjure)
3. [Syntax highlighting for fennel](https://github.com/bakpakin/fennel.vim)
4. [Fennel for Neovim](https://github.com/Olical/aniseed)

### Optional requirements
- [Neovide](https://github.com/neovide/neovide)

### How to install the requirements?
- First run clone_required.sh which will install everything mentioned in 'Other Requirements' section to `stdpath('data')/site/pack/start/`. This will ensure that fennel support is there. `fennel.lua` is already provided with the repo. This script will also copy the sample `.vdoom.d` to $HOME.
- `install_fonts.sh` will copy Ubuntu Mono to `~/.local/share/fonts` and run `fc-cache -r`
- Install the required luarocks. 
- Install `fdfind` and `rg` with your distro's package manager. 
- Now start doom and run `:PackerSync`

## How to update?
Just run `git pull` in `~/.config/nvim`.

## Further reading
1. [Caveats](caveats.md)
2. [Explanation of how doom works](doom-internals.md)
3. [How to configure doom](doom-configuration-guide.md)
4. [User configuration guide](user-configuration-guide.md)

## Screenshots

## Future plans
1. Add support to a variety of languages
2. Get nvim-dap up and working. 

## Contributing
I plan to make this a nice stable distribution. However, I need help maintaining this. Any volunteers are welcome here anytime!
