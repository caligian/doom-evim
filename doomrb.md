# doom.rb

This script's purpose is to provide an easy way to bootstrap doom-evim for the first time. 

Before you use this script, ensure that you have installed `ruby, fdfind, rg, node, lua5.1, luarocks`.
After you install node, please installed `yarn`. This is required to build the Markdown Preview mode in one of the doom packages.

## Help
<table>

<tr>
<td>Command</td>
<td>Usage</td>
</tr>

<tr>
<td>bootstrap</td>
<td>Install essential packages required by doom (eg. packer.nvim, which-key.nvim, etc).</td>
</tr>

<tr>
<td>setup-lua</td>
<td>Install the required luarocks: lua-path, set-lua, lualogging, etc</td>
</tr>

<tr>
<td>make-user-fs</td>
<td>Copy files from sample_user_configs/ to ~/.vdoom.d/.</td>
</tr>

<tr>
<td>install-fonts</td>
<td>Add your Nerd Font zips to misc/fonts and they will be installed.</td>
</tr>

<tr>
<td>setup-all</td>
<td>Do all of the above</td>
</tr>

</table>

## Usage
In order to use this script, you just have pass one of the above strings.
