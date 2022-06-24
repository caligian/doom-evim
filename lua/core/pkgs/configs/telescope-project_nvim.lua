local telescope = require('telescope')

telescope.load_extension('project')

kbd.new('n', '<leader>pp', partial(telescope.extensions.project.project, ts.defaults.opts), false, 'Show projects'):enable()
