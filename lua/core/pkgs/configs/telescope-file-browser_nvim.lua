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

kbd.new('n', '<leader>fF', partial(t.extensions.file_browser.file_browser, ts.defaults.opts), false, 'Launch file browser'):enable()
