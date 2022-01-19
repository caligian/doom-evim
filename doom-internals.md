# Doom-evim internals
Doom-evim is not a framework or a distribution per se. It is an abstraction provided (a rather thin one) by a set of functions. This section intends to acquaint the user with how stuff actually works. 

## Directory structure of doom-evim
- `fnl/` holds the heart and soul of doom
- `lua/` holds fennel.lua that is used by doom to compile lisp to lua. It also contains `modeline.lua` that configures the statusline. Rest of the lua files are made by aniseed as `<filename>.lua` by compiling `<filename>.fnl`. However, any files other than fennel.lua and modeline.lua are to be ignored.
- `vim/` contain vimscript plugins that will be manually sourced in `init.lua`
- `ftplugin/` contain filetype-related configurations.

These are the only files that affect the working of doom-evim. The real stuff lies in `fnl/` if you ever wish to take a look at the source code. 

### File descriptions
- [init.fnl](fnl/init.md)
- [utils.fnl](fnl/utils.md)
- [packages.fnl](fnl/packages.md)
- [package-utils.fnl](fnl/package-utils.md)
- 

