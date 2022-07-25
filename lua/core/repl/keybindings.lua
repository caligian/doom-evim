local kbd = require('core.kbd')
local repl = require('core.repl')

local function start_job(d, is_shell)
    d = d or 's'
    local j = false

    if is_shell then
        j = repl.new(false, {shell=true})
    else
        j = repl.new()
    end

    if j then
        j:start()
        j:show(d)
    end
end

local function kill_repl(is_shell)
    local j = false
    if is_shell then
        j = repl.find('shell')
    else
        j = repl.find(vim.bo.filetype)
    end

    if j then
        j:kill()
    end
end

local function send_string(method, is_shell)
    method = method or '.'
    local j = false

    if is_shell then
        j = repl.new(false, {shell=true})
    else
        j = repl.new()
    end

    if j then
        j:send(method)
    end
end

kbd.new('replsendvisualrange', 'v', '<localleader>,.', partial(send_string, 'v'), false, 'Send visual range to ' .. Doom.langs.shell):enable()
kbd.new('replsendcurrentline', 'n', '<localleader>,~', partial(send_string, '~.'), false, 'Send everything till current line to ' .. Doom.langs.shell):enable()
kbd.new('replsendbuffer', 'n', '<localleader>,b', partial(send_string, '~'), false, 'Send everything to ' .. Doom.langs.shell):enable()
kbd.new('replsendcurrentline', 'n', '<localleader>,.', partial(send_string, '.'), false, 'Start current line to ' .. Doom.langs.shell):enable()

kbd.new('replshellsendvisualrange', 'v', '<localleader>t.', partial(send_string, 'v', Doom.langs.shell), false, 'Send visual range to buffer REPL'):enable()
kbd.new('replshellsendcurrentline', 'n', '<localleader>t.', partial(send_string, '.', Doom.langs.shell), false, 'Send current line to buffer REPL'):enable()
kbd.new('replshellsendtillcurrentline', 'n', '<localleader>t~', partial(send_string, '~.', Doom.langs.shell), false, 'Send everything till line to REPL'):enable()
kbd.new('replshellsendbuffer', 'n', '<localleader>tb', partial(send_string, '~', Doom.langs.shell), false, 'Send buffer to REPL'):enable()

kbd.new('replshellsplit', 'n', '<localleader>ts', partial(start_job, 's', true), false, 'Start shell in split'):enable()
kbd.new('replshellvsplit', 'n', '<localleader>tv', partial(start_job, 'v', true), false, 'Start shell in vsplit'):enable()
kbd.new('replshelltab', 'n', '<localleader>tt', partial(start_job, 't', true), false, 'Start shell in tab'):enable()
kbd.new('replshellfloat', 'n', '<localleader>tf', partial(start_job, 'f', true), false, 'Start shell in floating win'):enable()

kbd.new('replstartsplit', 'n', '<localleader>,s', partial(start_job, 's'), false, 'Start REPL for buffer in split'):enable()
kbd.new('replstartvsplit', 'n', '<localleader>,v', partial(start_job, 'v'), false, 'Start REPL for buffer in vsplit'):enable()
kbd.new('replstarttab', 'n', '<localleader>,t', partial(start_job, 't'), false, 'Start REPL for buffer in tab'):enable()
kbd.new('replstartfloat', 'n', '<localleader>,f', partial(start_job, 'f'), false, 'Start REPL for buffer in floating win'):enable()

kbd.new('replkillall', 'n', '<localleader>,K', repl.killall, false, 'Kill all REPLs'):enable()
kbd.new('revplkillfiletype', 'n', '<localleader>,k', kill_repl, false, 'Kill buffer REPL'):enable()
kbd.new('replkillshell', 'n', '<localleader>tk', partial(kill_repl, true), false, 'Kill shell REPL'):enable()
