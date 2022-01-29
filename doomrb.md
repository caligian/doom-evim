# doom.rb

This script's purpose is to provide an easy way to bootstrap doom-evim for the first time. 

Before you use this script, ensure that you have installed `ruby, fdfind, rg, node, lua5.1, luarocks`.
After you install node, please run 

## Help

|command|usage|
--- | --- | --- |
bootstrap|Install essential packages required by doom (eg. packer.nvim, which-key.nvim, etc).|
setup-lua|Install the required luarocks: lua-path, set-lua, lualogging, etc|
make-user-fs|Copy files from `sample_user_configs/` to `~/.vdoom.d/`. These are the user configuration files|
install-fonts|Add your Nerd Font zips to misc/fonts and they will be installed. Default: Roboto Mono|
setup-all|Do all of the above|


## Usage
In order to use this script, you just have pass one of the above strings.
