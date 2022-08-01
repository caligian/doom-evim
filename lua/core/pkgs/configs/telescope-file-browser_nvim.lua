local t = require("telescope")

t.setup {
    extensions = {
        file_browser = {
            theme = 'ivy';
            hijack_netrw = true;
        }
    }
}

t.load_extension("file_browser")

kbd.new('ts_filebrowser', 'n', '<leader>fF', partial(t.extensions.file_browser.file_browser, telescope.defaults), false, 'Launch file browser')
