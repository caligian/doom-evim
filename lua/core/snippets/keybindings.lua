local st = require('core.snippets')
kbd('n', '<leader>&ss', st.new, false, 'Edit a new snippet in split'):enable()
kbd('n', '<leader>&sv', st.new, false, 'Edit a new snippet in vsplit'):enable()
kbd('n', '<leader>&sf', st.new, false, 'Edit a new snippet in floating win'):enable()
