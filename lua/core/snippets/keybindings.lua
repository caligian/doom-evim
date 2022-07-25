local st = require('core.snippets')

kbd.new('snippetnewsplit', 'n', '<leader>&ss', partial(st.new, 's'), false, 'Edit a new snippet in split'):enable()
kbd.new('snippetnewvspit', 'n', '<leader>&sv', partial(st.new, 'v'), false, 'Edit a new snippet in vsplit'):enable()
kbd.new('snippetnewfloat', 'n', '<leader>&sf', partial(st.new, 'f'), false, 'Edit a new snippet in floating win'):enable()
kbd.new('snippetnewtab', 'n', '<leader>&st', partial(st.new, 't'), false, 'Edit a new snippet in floating win'):enable()
