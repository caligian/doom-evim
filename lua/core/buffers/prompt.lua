local Fs = require('path.fs')
local String = require('aniseed.string')
local Path = require('path')
local Class = require('classy')
local Kbd = require('core.doom-kbd')
local Utils = require('core.doom-utils')
local Prompt = Class('doom-buffer-prompt')

-- Contains all the prompts
Prompt.inputs = {}

function Prompt:__init(float_win_obj)
    self.buffer = float_win_obj.buffer
    self.win = float_win_obj
end

function Prompt:show()
    self.buffer.float:show()
end

function Prompt:hide()
    self.buffer.float:hide()
end

-- Anything start with # will be considered as a comment while
-- accepting input from that buffer
-- Just provide lines for text and # will be prepended to each line
function Prompt:float(text, opts)
    opts = opts or {}

    if type(text) == 'string' then
        text = vim.split(text, "[\n\r]+")
    end

    for index, value in ipairs(text) do
        text[index] = '# ' .. value
    end

    self.win:show()

    vim.api.nvim_put(text, 'c', true, true)

    self.buffer:kbd {
        leader = false,
        keys = 'gs',
        help = 'Get input',
        exec = function ()
            vim.schedule(function ()
                local buffer_string = vim.api.nvim_buf_get_lines(0, 0, self.buffer:count(), false)

                for index, value in ipairs(buffer_string) do
                    if value:match('^ *#') then
                        buffer_string[index] = nil
                    end
                end

                if opts.hook then
                    opts.hook(buffer_string)
                end
            end)

            self.win:hide()
        end
    }
end

function Prompt.default(prompts_hooks_t, opts)
    opts = opts or {}
    local all_responses = {}
    local collect = opts.collect or false
    local collect_hook = opts.collect_hook
    local iterator = ipairs
    local n = #(Utils.keys(prompts_hooks_t))

    if n == 0 and #prompts_hooks_t > 0 then
        iterator = ipairs
    elseif n > 0  then
        iterator = pairs
    else
        iterator = ipairs
        table.insert(prompts_hooks_t, {'%', true})
    end

    local function _getInput(varname, prompt, f, loop)
        loop = loop or false

        if f == false or f == nil then
            f = false
        else
            f = function (s)
                if #s > 0 then
                    return s
                else
                    return false
                end
            end
        end

        local input = vim.fn.input(prompt .. ' % ')
        local resp = false

        if f then
            resp = f(input)
        elseif #input > 0 then
            resp = input
        end

        if not resp or resp:match('EOF') then
            resp = false
        end

        if resp and collect then
            if not all_responses[varname] then
                all_responses[varname] = {}
            end
            table.insert(all_responses[varname], resp)

            if collect_hook then
                collect_hook(resp)
            end
        end

        if resp ~= false then
            all_responses[varname] = resp
        elseif loop and not resp then
            _getInput(varname, prompt, f, loop)
        end
    end

    for var, prompt_f in iterator(prompts_hooks_t) do
        _getInput(var, prompt_f[1], prompt_f[2], opts.loop)

        if type(all_responses[var]) == 'table' then
            all_responses[var] = table.concat(all_responses[var], "\n")
        end
    end

    return all_responses
end

return Prompt
