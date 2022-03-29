local Snippet = {}
local Str = require('aniseed.string')
local Utils = require('doom-utils')
local BufUtils = require('doom-buffer-utils')
local Core = require('aniseed.core')
local Fs = require('path.fs')
local Path = require('path')
local Kbd = require('doom-kbd')

local savePath = Path(vim.fn.stdpath('data'), 'doom-snippets')

if not vim.g.vsnip_snippet_dirs then
    vim.g.vsnip_snippet_dir = savePath
end

vim.g.vsnip_snippet_dir = savePath

if not Path.exists(savePath) then
    Fs.mkdir(savePath)
end

Snippet = {
    directory = savePath,
}

function Snippet.save(ft, snippet)
    local saveAt = Path(savePath, ft .. '.json')

    if not Path.exists(saveAt) then
        Core.spit(saveAt, vim.fn.json_encode(snippet))
    else
        local existing = vim.fn.json_decode(Core.slurp(saveAt))
        existing = vim.tbl_deep_extend('force', existing, snippet)
        Core.spit(saveAt, vim.fn.json_encode(existing))
    end
end

function Snippet.saveFromString(name, prefix, ft, snippet)
    local t = {
        [name] = {
            prefix = prefix,
            body = snippet
        }
    }

    Snippet.save(ft, t)
end

function Snippet.new()
    Kbd.new({
        leader = false,
        keys = 'gx',
        help = 'Save snippet',
        pattern = vim.fn.expand('%'),
        event = 'BufEnter',
        exec = function ()
            local userInput = Utils.getUserInput({
                name = {'Name', true},
                prefix = {'Abbreviation to expand', true},
            })

            local buffer = BufUtils.getSubstring(0, {fromRow = 0, toRow = -1, concat = true})

            if #buffer > 0 then
                Snippet.saveFromString(userInput.name, userInput.prefix, vim.bo.filetype, buffer)
            end
        end
    })
end


function Snippet.splitEdit(buffer, opts)
    buffer = buffer or 0
    opts = opts or {}
    local previousBufferFt = opts.ft or vim.bo.filetype

    BufUtils.loadTemporaryBuffer(
    buffer,
    opts.direction or 'sp',
    {
        reverse = false,
        hook = opts.hook or function ()
            vim.bo.filetype = previousBufferFt
            Snippet.new()
        end
    })
end

function Snippet.vsplitEdit(buffer, opts)
    opts = opts or {}
    opts.direction = 'vsp'
    Snippet.splitEdit(buffer, opts)
end

function Snippet.makeKeybindings()
    Kbd.new({
        leader = 'l',
        keys = '&ss',
        help = 'Create a new snippet',
        name = 'Snippets & Templates',
        exec = Snippet.splitEdit,
    },
    {
        leader = 'l',
        keys = '&sv',
        help = 'Create a new snippet [vsp]',
        exec = Snippet.vsplitEdit,
    })
end

return Snippet
