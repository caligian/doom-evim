local kbd = require('core.kbd')

kbd(false, false, 'n,v', false, '<leader>bz', ':ZenMode', 'Activate distraction-free mode', {noremap=true}):enable()
