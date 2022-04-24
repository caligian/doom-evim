local Indent = {}
local Utils = require('doom-utils')
local BufUtils = require('doom-buffer-utils')

function Indent.indent(fromRow, toRow, opts)
    opts = opts or {}
    fromRow = fromRow or BufUtils.getCursorPosition().row
    toRow = toRow or fromRow+1
    local visual = opts.visual or false
    local times = opts.times or 1
    local linesOnly = not opts.linesOnly == false and not opts.linesOnly and true or false
    local count = opts.count

    if count and vim.v.count > 0 then
        times = vim.v.count
    end

    if visual then
        linesOnly = false
        local visualCood = BufUtils.getVisualCursorPosition()
        fromRow = visualCood.startRow
        toRow = visualCood.endRow
    end

    if linesOnly then
        if count and vim.v.count > 0 then
            toRow = toRow + vim.v.count
        else
            toRow = toRow + times
        end
        times = 1
    end

    local function _indentLine(lineNumber, times)
        local sw = vim.bo.shiftwidth or 4
        local currentLine = BufUtils.getSubstring(0, {
            fromRow = lineNumber,
        })[1]

        if currentLine then
            local a,b = currentLine:find('^ +')

            if b then
                local spacesLen = 0

                if b % sw == 0 then
                    spacesLen = sw
                else
                    spacesLen = b % sw
                end

                if opts.forwards then
                    BufUtils.setSubstring(
                    opts.buffer or 0,
                    {string.rep(' ', spacesLen + sw * (times - 1))},
                    {
                        fromRow = lineNumber,
                        toRow = lineNumber,
                        fromColumn = 0,
                        toColumn = 0,
                    })
                elseif opts.backwards then
                    if spacesLen > b then
                        spacesLen = b
                    elseif spacesLen * times >= b then
                        spacesLen = b
                    end

                    BufUtils.setSubstring(
                    opts.buffer or 0,
                    {},
                    {
                        fromRow = lineNumber,
                        toRow = lineNumber,
                        fromColumn = 0,
                        toColumn = spacesLen,
                    })
                end
            end
        end
    end

    for i=fromRow,toRow-1 do
        _indentLine(i, opts.times or 1)
    end
end

return Indent
