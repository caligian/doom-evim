local kbd = require('core.kbd')
--local repl = require('core.repl')
local repl = dofile('init.lua')

local function start_job(d, is_shell)
    if not is_shell and not assoc(Doom.langs, {vim.bo.filetype, 'repl'}) then
        to_stderr('No repl defined for filetype %s in Doom.langs', vim.bo.filetype)
        return
    end

    d = d or 's'
    local j = false

    if is_shell then
        j = Doom.repl.status['shell-repl']
    else
        j = repl.find_job(vim.bo.filetype)
    end

    if j and j.running then
        if d == 's' then
            j.buffer:split()
        elseif d == 'v' then
            j.buffer:vsplit()
        elseif d == 't' then
            j.buffer:tabnew()
        else
            j.buffer:to_win()
        end

        return j
    end

    if is_shell then
        j = repl(false, {shell=true}, false, false)
    else
        j = repl(false, {}, false, false)
    end

    j:open()

    if d == 's' then
        j.buffer:split()
    elseif d == 'v' then
        j.buffer:vsplit()
    elseif d == 't' then
        j.buffer:tabnew()
    else
        j.buffer:to_win()
    end

    return j
end

local function _kill(_, is_shell)
    if not is_shell and not assoc(Doom.langs, {vim.bo.filetype, 'repl'}) then
        to_stderr('No repl defined for filetype %s in Doom.langs', vim.bo.filetype)
        return
    end

    local j = false
    if is_shell then
        j = Doom.repl.status['shell-repl']
    else
        j = assoc(Doom.repl.status, vim.bo.filetype .. '-repl')
    end

    if j and j.running then
        j:delete()
        to_stderr('Killed REPL for filetype ' .. vim.bo.filetype)
    end
end

local function send_string(method, is_shell)
    if not is_shell and not assoc(Doom.langs, {vim.bo.filetype, 'repl'}) then
        to_stderr('No repl defined for filetype %s in Doom.langs', vim.bo.filetype)
        return
    end

    method = method or '.'
    local j = false

    if is_shell then
        j = Doom.repl.status['shell-repl']
    else
        j = assoc(Doom.repl.status, vim.bo.filetype .. '-repl')
    end

    if j and j.running then
        j:send_from_buffer(method)
        return
    end

    if is_shell then
        j = repl(false, {shell=true}, false)
    else
        j = repl(false, {}, false)
    end

    j:open()
    j:send_from_buffer(method)
end

kbd('v', '<localleader>,.', partial(send_string, 'v'), false, 'Send visual range to ' .. Doom.langs.shell):enable()
kbd('n', '<localleader>,~', partial(send_string, '~.'), false, 'Send current line to ' .. Doom.langs.shell):enable()
kbd('n', '<localleader>,b', partial(send_string, '~'), false, 'Send everything till line to ' .. Doom.langs.shell):enable()
kbd('n', '<localleader>,.', partial(send_string, '.'), false, 'Start buffer to ' .. Doom.langs.shell):enable()

kbd('v', '<localleader>t.', partial(send_string, 'v', Doom.langs.shell), false, 'Send visual range to buffer REPL'):enable()
kbd('n', '<localleader>t~', partial(send_string, '~.', Doom.langs.shell), false, 'Send current line to buffer REPL'):enable()
kbd('n', '<localleader>tb', partial(send_string, '~.', Doom.langs.shell), false, 'Send everything till line to REPL'):enable()
kbd('n', '<localleader>t.', partial(send_string, '.', Doom.langs.shell), false, 'Start buffer to REPL'):enable()

kbd('n', '<localleader>ts', partial(start_job, 's', true), false, 'Start REPL for buffer in split'):enable()
kbd('n', '<localleader>tv', partial(start_job, 'v', true), false, 'Start REPL for buffer in vsplit'):enable()
kbd('n', '<localleader>tt', partial(start_job, 't', true), false, 'Start REPL for buffer in tab'):enable()
kbd('n', '<localleader>tf', partial(start_job, 'f', true), false, 'Start REPL for buffer in floating win'):enable()

kbd('n', '<localleader>,s', partial(start_job, 's'), false, 'Start REPL for buffer in split'):enable()
kbd('n', '<localleader>,v', partial(start_job, 'v'), false, 'Start REPL for buffer in vsplit'):enable()
kbd('n', '<localleader>,t', partial(start_job, 't'), false, 'Start REPL for buffer in tab'):enable()
kbd('n', '<localleader>,f', partial(start_job, 'f'), false, 'Start REPL for buffer in floating win'):enable()

kbd('n', '<localleader>,K', repl.killall, false, 'Kill all REPLs'):enable()
kbd('n', '<localleader>,k', _kill, false, 'Kill buffer REPL'):enable()
kbd('n', '<localleader>tk', partial(_kill, true), false, 'Kill shell REPL'):enable()
