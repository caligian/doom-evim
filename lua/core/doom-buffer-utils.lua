local BufUtils = {}
local Utils = require('doom-utils')

function BufUtils.addBuffer(name, opts)
    local bufname = name
    local hook = opts.hook
    local settings = opts.settings or {}

    if vim.fn.bufnr(bufname) == -1 then
        vim.fn.bufadd(bufname)
    end

    local bufnr = vim.fn.bufnr(bufname)
    local hookOut = nil

    if hook then
        hookOut = hook()
    end

    for key, value in pairs(settings) do
        vim.api.nvim_buf_set_option(bufnr, key, value)
    end

    return hookOut
end

function BufUtils.getCursorPosition()
    local t = vim.call('getcurpos', 0)
    return {row = t[2] - 1, col = t[3] - 1}
end

function BufUtils.getVisualCursorPosition()
    local start_t = vim.call('getpos', "'<")
    local end_t = vim.call('getpos', "'>")

    return {
        startRow = start_t[2] - 1,
        startColumn = start_t[3] - 1,
        endRow = end_t[2] - 1,
        endColumn = end_t[3] - 1,
    }
end

function BufUtils.isValidBuffer(buf, newBufName, newBufOpts)
    print(buf)
    assert(type(buf) == 'number' or type(buf) == 'string')

    if type(buf) == 'number' then
        if buf == 0 then
            buf = vim.fn.bufnr()
        end

        if vim.fn.bufnr(buf) == -1 then
            if newBufName then
                BufUtils.addBuffer(newBufName, {settings = newBufOpts})
                return vim.fn.bufnr(newBufName)
            else
                return false
            end
        else
            return vim.fn.bufnr(buf)
        end
    elseif type(buf) == 'string' then
        if vim.fn.bufname(buf) == '' then
            if newBufName then
                BufUtils.addBuffer(newBufName, {settings = newBufOpts})
                return vim.fn.bufnr(newBufName)
            else
                return false
            end
        else
            return vim.fn.bufnr(buf)
        end
    end
end

function BufUtils.splitEdit(buffer, newBuffer, direction, opts)
    local current_buffer = BufUtils.isValidBuffer(buffer or 0, buffer, {})
    local new_buffer = BufUtils.isValidBuffer(newBuffer, newBuffer, opts.settings)
    local reverse = opts.reverse or false
    local split_direction = direction or 'sp'
    local hook = opts.hook

    current_buffer = BufUtils.isValidBuffer(current_buffer)
    new_buffer = BufUtils.isValidBuffer(new_buffer, new_buffer, opts.settings)

    if not reverse then
        if split_direction == 'sp' then
            vim.cmd(string.format(':split | wincmd j | buffer %s', new_buffer))
        elseif split_direction == 'vsp' then
            vim.cmd(string.format(':vsplit | wincmd l | buffer %s', new_buffer))
        elseif split_direction == 'tab' then
            vim.cmd(string.format(':tabnew | buffer %s', new_buffer))
        end
    else
        if split_direction == 'sp' then
            vim.cmd(string.format(':split | buffer %s', new_buffer))
        elseif split_direction == 'vsp' then
            vim.cmd(string.format(':vsplit | buffer %s', new_buffer))
        elseif split_direction == 'tab' then
            vim.cmd(string.format(':tabnew | buffer %s', new_buffer))
        end
    end

    if hook then return hook() end
end

-- All coordinates must be zero-indexed
function BufUtils.getSubstring(buffer, opts)
    buffer = BufUtils.isValidBuffer(buffer)
    opts = opts or {}

    if not buffer then
        return false
    else
        local current_pos = BufUtils.getCursorPosition()
        local fromRow = opts.fromRow or current_pos.row
        local toRow = opts.toRow or fromRow + 1
        local toColumn = opts.toColumn
        local fromColumn = opts.fromColumn
        local concat = opts.concat or false
        local all = opts.all or false

        if opts.visual then
            local cood = BufUtils.getVisualCursorPosition()
            fromRow = cood.startRow
            fromColumn = cood.startColumn
            toRow = cood.endRow
            toColumn = cood.endColumn
        end

        if all then
            return vim.api.nvim_buf_get_lines(buffer, 0, -1, false)
        elseif fromColumn or toColumn then
            local current_line = vim.call('getline', current_pos.row + 1)
            fromColumn = fromColumn or 0
            toColumn = toColumn or #current_line

            local bufstr = vim.api.nvim_buf_get_text(buffer, fromRow, fromColumn, toRow, toColumn, {})

            if concat then
                return table.concat(bufstr, "\n")
            else
                return bufstr
            end
        else
            local bufstr = vim.api.nvim_buf_get_lines(buffer, fromRow, toRow, false)
            if concat then
                return table.concat(bufstr, "\n")
            else
                return bufstr
            end
        end
    end
end

function BufUtils.setSubstring(buffer, lines, opts)
    opts = opts or {}
    local fromRow = opts.fromRow
    local fromColumn = opts.fromColumn
    local toRow = opts.toRow
    local toColumn = opts.toColumn
    local insert_lines = opts.linesOnly or false
    local insert_not_replace = opts.insert or false
    local insert_type = opts.type or 'c'
    local follow_insert = opts.follow or false
    local insert_after = not opts.after == false and not opts.after and true or false
    local lines = lines or {}
    buffer = BufUtils.isValidBuffer(buffer or 0, buffer, {})
    local delete = opts.delete or false

    if opts.visual then
        local vcood = BufUtils.getVisualCursorPosition()
        fromRow = vcood.startRow
        toRow = vcood.endRow
        fromColumn = vcood.startColumn
        toColumn = vcood.endColumn
    end

    if delete then
        local pos = BufUtils.getCursorPosition()
        local fromRow, toRow = nil, nil
        local fromColumn, toColumn = nil, nil

        fromRow = opts.fromRow or pos.row
        toRow = opts.toRow or vim.api.nvim_buf_line_count(buffer) - 1
        fromColumn = opts.fromColumn or 0

        local current_line = BufUtils.getSubstring(buffer, {
            fromRow = toRow,
        })

        toColumn = opts.toColumn or #(current_line[1]) - 1

        vim.api.nvim_buf_set_text(buffer, fromRow, fromColumn, toRow, toColumn, {})
    elseif not insert_not_replace then
        local pos = BufUtils.getCursorPosition()
        local curRow = pos.row
        local curCol = pos.col

        if type(lines) == 'string' then
            lines = vim.split(lines, "[\n\r]+")
        end

        if not insert_lines then
            fromRow = fromRow or curRow
            toRow = toRow or fromRow + #lines
            fromColumn = fromColumn or 0
            toColumn = toColumn or #(vim.call('getline', toRow+1))

            vim.api.nvim_buf_set_text(bufnr, fromRow, fromColumn, toRow, toColumn, lines)
        else
            fromRow = fromRow or curRow
            toRow = toRow or fromRow + #lines
            vim.api.nvim_buf_set_lines(bufnr, fromRow, toRow, false, lines)
        end
    elseif insert_not_replace then
        if type(lines) == 'string' then
            lines = vim.split(lines, "[\n\r]+")
        end

        vim.api.nvim_put(lines, insert_type, insert_after, follow_insert)
    end
end

function BufUtils.loadTemporaryBuffer(buffer, direction, opts)
    opts = opts or {}
    local lines = opts.lines or {}
    local input = opts.input or false
    local hook = opts.hook
    buffer = BufUtils.isValidBuffer(buffer, buffer)
    direction = direction or 'sp'
    local temp_buf_name = ''

    if type(lines) == 'string' then
        lines = vim.split(lines, "[\n\r]+")
    end

    if not Doom.temporaryBuffers then
        Doom.temporaryBuffers = {}
        table.insert(Doom.temporaryBuffers, 'temp_buffer_1')
        temp_buf_name = 'temp_buffer_' .. #Doom.temporaryBuffers
    else
        if opts.index then
            temp_buf_name = 'temp_buffer_' .. opts.index
        else
            temp_buf_name = 'temp_buffer_' .. #Doom.temporaryBuffers + 1
            table.insert(Doom.temporaryBuffers, temp_buf_name)
        end
    end
        
    local reverse = opts.reverse or false

    if lines and #lines > 0 then
        return BufUtils.splitEdit(buffer, temp_buf_name, direction, {
            settings = {buftype = 'nofile'},
            hook = function ()
                BufUtils.setSubstring(temp_buf_name, lines, {insert = true})
                if hook and not input then
                    hook(temp_buf_name, lines)
                elseif hook and input then
                    hook(temp_buf_name, lines, Utils.getUserInput(input))
                end
            end,
            reverse = reverse,
        })
    else
        return BufUtils.splitEdit(buffer, temp_buf_name, direction, {
            settings = {buftype = 'nofile'},
            hook = opts.hook,
            reverse = reverse,
        })
    end
end



function BufUtils.setPos(bufnr, row, col, one_indexed)
    if one_indexed then
        row = row - 1

        if col then
            col = col - 1
        else
            col = 1
        end
    end

    col = col or row + 1
    vim.cmd(string.format(":call setpos('.',[0, %d, %d, %d])", bufnr, row, col, 0))
end

function BufUtils.makeRepeatable(exec, times, opts)
    opts = opts or {}

    if type(exec) == 'function' then
        exec = Utils.register(exec)
    end

    return function ()
        local bufnr = opts.buffer or 0
        bufnr = BufUtils.isValidBuffer(bufnr)
        local times = times or vim.v.count
        local linewise = opts.linewise or false
        local cood = BufUtils.getCursorPosition()
        local lineNumber = opts.line or cood.row
        local line = {0, lineNumber, cood.col, 0}

        if not linewise then
            BufUtils.setPos(bufnr, lineNumber)

            for i=1,times do
                vim.cmd(exec)
            end
        elseif opts.visual then
            local cood = BufUtils.getVisualCursorPosition()
            
            for i=cood.row,cood.row+times do
               BufUtils.setPos(bufnr, i)
               vim.cmd(exec)
            end
        else
            for i=lineNumber,lineNumber+times do
                BufUtils.setPos(bufnr, i)
                vim.cmd(exec)
            end
        end
    end
end

function BufUtils.put(lines, row, col, opts)
    opts = opts or {}
    local line = opts.line
    local buffer = BufUtils.isValidBuffer(0)

    if not opts.after == false and opts.after == nil then
        opts.after = true
    end

    if not opts.follow == false and opts.follow == nil then
        opts.follow = true
    end

    if buffer then
        if line then
            BufUtils.setPos(0, row, col)
        end

        vim.api.nvim_put(lines, opts.type or 'c', opts.after, opts.follow)
    end
end

function BufUtils.withVisualRange(buffer, f, str)
    assert(type(f) == "function")

    local buf = BufUtils.isValidBuffer(buffer or 0)

    if buf then
        if str then
            return function ()
                local cood = BufUtils.getVisualCursorPosition()

                return f(
                cood,
                BufUtils.getSubstring(buf, {
                    fromRow = cood.startRow,
                    toRow = cood.endRow,
                    fromColumn = cood.startColumn,
                    toColumn = cood.endColumn,
                }))
            end
        else
            return function ()
                return f(BufUtils.getVisualCursorPosition())
            end
        end
    end
end

return BufUtils
