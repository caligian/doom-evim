# init.fnl: How does doom-evim starts?
This section contains a brief description of how `init.fnl` loads doom to life. `init.fnl` contains 2 important types of code: 
- Managing global variables contained in `_G` and `_G.doom`
- Requiring other modules 

Some modules have side-effects. Therefore, not all of them are added to the global table. Some are simply required such as `(require :packages)`. On the other hand, the others return a set of utilities. They may also have side effects but are intended to be used by the user and the system. 

## Modules with side-effects
- [configs.fnl](configs.md)
- [keybindings.fnl](keybindings.md)
- [packages.fnl](packages.md)

## Modules containing utilities
- [utils.fnl](utils.md)
- [package-utils.fnl](package-utils.md)
- [lsp-configs.fnl](lsp-configs.md)
- [logger.fnl](logger.md)

## Order of evaluation
1. `(require :logger)` to get the default logger and append to `stdpath('data')/doom-evim.log`
2. Global tables are made: `doom`, `doom.lsp` and `doom.utils`. Since `utils` is required as a module, it is set directly. 
3. Via `(require :packages)`, `packages` loads `package-utils` and parses the list of packages in `~/.vdoom.d/user-packages.lua` and also uses the internal package list to make the final list of packages. Then `package-utils` is required by `packages` to obtain the final list which is sent to `packer` for `packer.startup(...)`.
4. User overrides for doom options are required via `(require :user-init)`. This is important as several doom options are instrumental in setting up lsp and configuring packages. 
5. `(require :lsp-configs)` is used to setup LSP. This also depends on whether the user wants to use the default LSP setup or not
6. pending

