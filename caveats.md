
# Caveats
This section contains some of the gotchas that may get you. It is important you read this section with attention.

- How to know if something's gone wrong? 
    `~/.local/share/nvim/doom-evim.log` contains the startup log.
- How do I update doom? 
    `git pull` should do it. That being said, your local configs will be overwritten. So stash it if you want to preserve yours.
- Why fennel integration?
    In my experience, lisp is a really nice form to use and much clearer than other languages. Since fennel is a lisp parser than being a separate language, lua support is DIRECT.
- Is lua configuration supported?
    Of course. You can use it with fennel as long as it **DOES NOT CONFLICT WITH YOUR LUA CONFIG**.
- Why is not nvim-dap included?
    I could not get it to work despite following every instruction as-is. If you are able to get it to work, please share your private doom config. 
- Why is only ruby and python provided with goodies?
    Because I am not that fluent in multiple languages. lua, ruby, python, bash, clojure and perl are all I know. I am just a hobby coder. So, it is up to you to set up your setup. `treesitter` and `nvim-lsp` and `nvim-cmp` are already configured. `:LspInstall <lang>` and `:TSInstall <lang>` are your friends. I assumed that this is enough to get anybody to start with their own configuration.
- Why does not telescope work?
    Neovim 0.5 and above is required.
- Can I not use the default configuration? 
    Yes. You can disable packages by commenting packages in ~/.vdoom.d/user-packages.lua. New packages will be added automatically. All the packer-forms will be accessible in doom.packages.
- Can I disable default LSP configuration
    Yes you can set `doom.lsp.load_default = false`. You have to set LSP configuration all by your own now :(
- Why cannot I see my help-group in which-key? 
    You have to manually set the keys in global var map-help-groups.
- Why is my fennel configuration not loading?
    Don't make modules. Just return a table or any true value as you would while writing a normal lua plugin.
- Why cannot I use new packages after I append to user-packages.lua?
    You need to rerun neovim and run `:PackerInstall`. This is done to preent breakage of any package as soon as it is installed.
