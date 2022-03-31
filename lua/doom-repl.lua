local Utils = dofile("doom-utils.lua")
local Kbd = dofile('doom-kbd.lua')
local Str = require('aniseed.string')
local BufUtils = require('doom-buffer-utils')

local Repl = {
    ftExecutables = {
        ruby = 'pry',
        lua = 'lua5.1',
        python = 'python3',
        sh = 'bash',
    },
}

function Repl.new(opts)
    opts = opts or {}
    local ft = opts.ft or vim.bo.filetype
    local bin = opts.bin or Repl.ftExecutables[ft]
    local alreadyActive = Repl.active[bin]

    if not alreadyActive then
        vim.cmd('tabnew')
        vim.fn.termopen(bin)

        vim.bo.buflisted = false
        vim.wo.number = false

        local bufnr = vim.fn.bufnr()
        local bufname = vim.fn.expand('%')

        Repl.active[bin] = {
            bufnr = bufnr,
            cmd = bin,
            id = vim.b.terminal_job_id,

            delete = function ()
                print('Shutting down REPL: ' .. bin)
                Repl.active[bin] = nil
                vim.cmd(string.format(':bwipeout! %s', bufname))
            end,

            print = function ()
                print(string.format('Buffer: %d  REPL: %s', bufnr, bin))
            end,

            split = function (direction)
                direction = direction or 'sp'
                local winbufnr = vim.fn.bufwinnr(bufnr)

                if winbufnr == -1 then
                    if direction == 'sp' then
                        vim.cmd('split | wincmd j | b ' .. bufnr)
                    elseif direction == 'vsp' then
                        vim.cmd('vsplit | wincmd l | b ' .. bufnr)
                    else
                        vim.cmd('tabnew | b ' .. bufnr)
                    end
                end
            end
        }

        vim.cmd('q')
        vim.cmd('tabprev')
    end
end

function Repl.delete(bin, opts)
    opts = opts or {}
    local ft = opts.ft or vim.bo.filetype
    bin = bin or Repl.ftExecutables[ft]

    if bin and Repl.active[bin] then
        Repl.active[bin].delete()
    end
end

function Repl.sendString(what, opts)
    opts = opts or {}
    what = what or 'line'
    local ft = opts.ft or vim.bo.filetype
    local bin = opts.bin or Repl.ftExecutables[ft]
    local bufnr = opts.buffer or 0
    local lines = opts.lines or nil
    local count = vim.v.count
    local fromRow, toRow = 0, 0

    if Repl.auto then
        Repl.new({bin = bin})
    end

    if not lines and bin and Repl.active[bin] then
        local cursorpos = BufUtils.getCursorPosition()

        if count > 0 then
            lines = BufUtils.getSubstring(bufnr, {
                fromRow = cursorpos.row,
                toRow = cursorpos.row + count,
            })
        elseif what == 'line' then
            lines = BufUtils.getSubstring(bufnr)
        elseif what == 'till-point' then
            lines = BufUtils.getSubstring(bufnr, {
                fromRow = 0,
                toRow = cursorpos.row
            })
        elseif what == 'visual' then
            cursorpos = BufUtils.getVisualCursorPosition()

            lines = BufUtils.getSubstring(bufnr, {
                fromRow = cursorpos.startRow,
                toRow = cursorpos.endRow,
                fromColumn = cursorpos.startColumn,
                toColumn = cursorpos.toColumn
            })
        end

        if lines and type(lines) == 'table' then
            lines = table.concat(lines, "\n")
        end

        vim.fn.chansend(Repl.active[bin].id, lines .. "\n\r")
    elseif lines and Repl.active[bin] then
        if lines and type(lines) == 'table' then
            lines = table.concat(lines, "\n")
        end

        if Repl.active[bin] then
            vim.fn.chansend(Repl.active[bin].id, lines .. "\n\r")
        end
    end
end

function Repl.bufferAction(action, direction, opts)
    direction = direction or 'sp'
    action = action or 'compile'
    opts = opts or {}
    local binary = false
    local currentFile = vim.fn.expand('%')
    local currentFileAbs = vim.fn.expand("%:p")
    local ft = opts.ft or vim.bo.filetype
    local shell = opts.shell or doom.shell or 'bash'

    if opts.binary then
        binary = opts.binary
    elseif doom.langs[ft] and doom.langs[ft][action] then
        binary = doom.langs[ft][action]['cmd']
    else
        print(string.format('No binary set for ft (%s) for action (%s)', ft, action))
        return false
    end

    local userInput = Utils.getUserInput({
        pipeArgs = {
            string.format('String to pipe into binary (%s)', binary),
            false
        },

        binaryArgs = {
            string.format('Arguments for binary (%s)', binary),
            false
        },

        fileArgs = {
            string.format('Arguments for file(%s)', currentFile),
            false,
        }
    })

    if #userInput.pipeArgs > 0 then
        userInput.pipeArgs = userInput.pipeArgs + ' | '
    end

    local cmd = string.format('%s %s %s %s', userInput.pipeArgs, binary, currentFileAbs, userInput.fileArgs)
    cmd = Str.trim(cmd)

    if Repl.auto then
        Repl.new({bin = shell})
    end

    Repl.sendString(false, {bin = shell, lines = cmd})
end

function Repl.split(direction, opts)
    opts = opts or {}
    direction = direction or 'sp'
    local ft = vim.bo.filetype
    local cmd = nil

    if Repl.auto and opts.bin then
        Repl.new({bin = opts.bin})
    elseif Repl.auto and Repl.ftExecutables[ft] then
        Repl.new({bin = Repl.ftExecutables[ft]})
    end

    if opts.bin then
        cmd = Repl.active[opts.bin]
    elseif Repl.ftExecutables[ft] then
        cmd = Repl.active[Repl.ftExecutables[ft]]
    end

    if cmd then
        cmd.split(direction)
    else
        print('No binary found for this filetype')
    end
end

function Repl.liveSend(opts)
    opts = opts or {}
    local bin = opts.bin or Repl.ftExecutables[vim.bo.filetype]

    if Repl.auto then
        Repl.new({bin = bin})
    end

    local userInput = Utils.getUserInput({
        cmd = {'Command to send to REPL [EOF to end input]', true}},
        {
            collect = true,
            collectHook = function (str)
                Repl.sendString(false, {lines = str, bin = bin})
            end
        })
end

function Repl.shutdown(opts)
    opts = opts or {}
    local ft = opts.ft or vim.bo.filetype
    local bin = opts.bin or Repl.ftExecutables[ft]

    if opts.shell then
        bin = opts.shell
    end

    if bin and Repl.active[bin] then
        Repl.active[bin].delete()
    end
end

function Repl.shutdownAll()
    for cmd, _ in pairs(Repl.active) do
        Repl.shutdown({bin = cmd})
    end
end

function Repl.makeKeybindings()
    Kbd.new({
        leader = 'll',
        keys = ',k',
        help = 'Kill ft REPL',
        exec = Repl.shutdown
    },
    {
        leader = 'll',
        keys = ',K',
        help = 'Kill shell REPL',
        exec = function ()
            Repl.shutdown({bin = doom.shell or 'bash'})
        end
    },
    {
        leader = 'll',
        keys = ',!',
        help = 'Kill all REPLs',
        exec = Repl.shutdownAll,
    },
    {
        leader = 'll',
        keys = ',t',
        help = 'Launch a REPL for this filetype',
        name = 'REPL Operations',
        exec = Repl.new,
    },
    {
        leader = 'll',
        keys = ',T',
        help = 'Launch shell',
        exec = function ()
            Repl.new({bin = doom.shell or 'bash'})
        end
    },
    {
        leader = 'll',
        keys = ',s',
        help = 'Split buffer with ft REPL',
        exec = Repl.split,
    },
    {
        leader = 'll',
        keys = ',v',
        help = 'vsplit buffer with ft REPL',
        exec = function ()
            Repl.split('vsp')
        end
    },
    {
        leader = 'll',
        keys = ',S',
        help = 'Split buffer with shell',
        exec = function ()
            Repl.split('sp', {bin = doom.shell or 'bash'})
        end
    },
    {
        leader = 'll',
        keys = ',V',
        help = 'Vsplit buffer with shell',
        exec = function ()
            Repl.split('vsp', {bin = doom.shell or 'bash'})
        end
    },
    {
        leader = 'll',
        keys = ',e',
        help = 'Send current line to ft REPL',
        exec = function ()
            Repl.sendString('line')
        end
    },
    {
        leader = 'll',
        keys = ',.',
        help = 'Send strings till point to ft REPL',
        exec = function ()
            Repl.sendString('till-point')
        end
    },
    {
        leader = 'll',
        mode = 'v',
        keys = ',e',
        help = 'Send visual range to ft REPL',
        exec = function ()
            Repl.sendString('visual')
        end
    },
    {
        leader = 'll',
        keys = ',E',
        help = 'Send current line to shell REPL',
        exec = function ()
            Repl.sendString('line', {bin = doom.shell or 'bash', count = true})
        end
    },
    {
        leader = 'll',
        keys = ',>',
        help = 'Send strings till point to shell REPL',
        exec = function ()
            Repl.sendString('till-point', {bin = doom.shell or 'bash'})
        end
    },
    {
        leader = 'll',
        mode = 'v',
        keys = ',E',
        help = 'Send visual range to shell REPL',
        exec = function ()
            Repl.sendString('visual', {bin = doom.shell or 'bash'})
        end
    },
    {
        leader = 'll',
        keys = ',;',
        help = 'Send a string to ft REPL',
        exec = function ()
        end
    },
    {
        leader = 'll',
        keys = ',:',
        help = 'Send strings to shell REPL',
        exec = function ()
            Repl.liveSend({bin = doom.shell or 'bash'})
        end
    },
    {
        leader = 'll',
        keys = 'mc',
        help = 'Compile current buffer in REPL',
        exec = Repl.bufferAction,
    },
    {
        leader = 'll',
        keys = 'md',
        help = 'Debug current buffer in REPL',
        exec = function ()
            Repl.bufferAction('debugger')
        end
    },
    {
        leader = 'll',
        keys = 'mb',
        help = 'Build current buffer in REPL',
        exec = function ()
            Repl.bufferAction('builder')
        end
    },
    {
        leader = 'll',
        keys = 'mt',
        help = 'Test current buffer in REPL',
        exec = function ()
            Repl.bufferAction('testing')
        end
    })
end

return Repl
