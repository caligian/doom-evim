local Template = {}
local Au = require('doom-au')
local Str = require('aniseed.string')
local Buffer = require('core.buffers')
local Core = require('aniseed.core')
local Fs = require('path.fs')
local Path = require('path')
local Kbd = require('doom-kbd')

local savePath = Path(vim.fn.stdpath('data'), 'doom-templates')
Template.savePath = savePath

if not Path.exists(savePath) then
    Fs.mkdir(savePath)
end

Template = {
    directory = savePath,
}

function Template.save(ft, template)
    local saveAt = Path(savePath, ft .. '.json')

    if not Path.exists(saveAt) then
        Core.spit(saveAt, vim.fn.json_encode(template))
    else
        local existing = vim.fn.json_decode(Core.slurp(saveAt))
        existing = vim.tbl_deep_extend('force', existing, template)
        Core.spit(saveAt, vim.fn.json_encode(existing))
    end
end

function Template.saveFromString(pattern, ft, template)
    local t = {
        [pattern] = template
    }

    Template.save(ft, t)
end

Template.saveFromString('nvim', 'lua', 'local Utils = require("doom-utils")')

function Template.new()
    Kbd.new({
        leader = false,
        keys = 'gx',
        help = 'Save template',
        pattern = vim.fn.expand('%'),
        event = 'BufEnter',
        exec = function ()
            local userInput = Utils.getUserInput({
                regex = {'Lua regex pattern to match', true},
            })

            local buffer = BufUtils.getSubstring(0, {fromRow = 0, toRow = -1, concat = true})

            if #buffer > 0 then
                Template.saveFromString(userInput.regex, vim.bo.filetype, buffer)
            end
        end
    })
end

function Template.splitEdit(buffer, opts)
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
            Template.new()
        end
    })
end

function Template.vsplitEdit(buffer, opts)
    opts = opts or {}
    opts.direction = 'vsp'
    Template.splitEdit(buffer, opts)
end

function Template.makeKeybindings()
    Kbd.new({
        leader = 'l',
        keys = '&ts',
        help = 'Create a new template',
        exec = Template.splitEdit,
    },
    {
        leader = 'l',
        keys = '&tv',
        help = 'Create a new template [vsp]',
        exec = Template.vsplitEdit,
    })
end

function Template.autoInsert(ft)
    ft = ft or vim.bo.filetype
    local templatePath = Path(savePath, ft .. '.json')
    local currentFilePath = vim.fn.expand('%:p')

    if Path.exists(templatePath) then
        for pattern, str in pairs(vim.fn.json_decode(Core.slurp(templatePath))) do
           if currentFilePath:match(pattern) then
               local lines = vim.split(str, "[\n\r]+")
               BufUtils.setSubstring(0, lines, {fromRow = 0, toRow = #lines})
           end
        end
    end
end

function Template.startInsertion()
    Au.autocmd('Global', 'BufEnter', '*', Template.autoInsert)
end

return Template
