local kbd = require('core.kbd')
kbd('BufEnter', '*lua', 'n', false, '<F3>', ':Luapad<CR>', 'Start live lua REPL'):enable()
