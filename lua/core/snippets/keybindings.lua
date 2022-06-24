local st = require('core.snippets')
kbd.new('n', '<leader>&ss', st.new, false, 'Edit a new snippet in split'):enable()
kbd.new('n', '<leader>&sv', st.new, false, 'Edit a new snippet in vsplit'):enable()
kbd.new('n', '<leader>&sf', st.new, false, 'Edit a new snippet in floating win'):enable()
