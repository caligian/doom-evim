local b = dofile('../../buffers/init.lua')
local kbd = require('core.kbd')
local a = dofile('../spawn.lua')
local ts = require('core.telescope')
local ab = class('doom-async-buffer-utils')

ab.status = {}

function ab:__init(ft, cmd)
    self.cmd = cmd
    self.filetype = ft
    self.jobs = {}
end

function ab.new(opts)
    opts = opts or {}
    ft = opts.ft or vim.bo.filetype
    local obj = assoc(ab.status, ft)

    if obj then
        if not opts.force then
            if obj.job.handle and not obj.job.handle:is_closing() then
                return obj
            end           
        end
    end

    local cmd = assoc(Doom.langs, {ft, 'compile'}) or opts.cmd
    assert(cmd, 'No command found for filetype: ' .. ft)

    return ab(ft, cmd)
end

function ab:add_buffer(opts)
    opts = opts or {}
    local fn = false
    opts.bufnr = opts.bufnr or vim.fn.bufnr()
    assert(vim.fn.bufexists(opts.bufnr) ~= 0, 'Invalid bufnr provided')

    if not vim.api.nvim_buf_call(opts.bufnr, function ()
        return vim.bo.filetype
    end) == self.filetype then
        return false
    end

    fn = vim.api.nvim_buf_call(opts.bufnr, function ()
        return vim.fn.expand('%:p')
    end)

    if self.jobs[fn] then
        return self.jobs[fn]
    end

    self.jobs[fn] = a.new(fn, self.cmd, {
        args = fn;
        stdout = true;
        stderr = true;
    })

    self.jobs[fn]:start()
end

function ab:cleanup()
    for key, value in pairs(self.jobs) do
        if value.done then
            self.jobs[key] = nil
        end
    end
end

function ab:show_output(d, win_opts)
    d = d or 'f'
    assert_s(d)

    self:cleanup()

    local function get_results(sel)
        local j = self.jobs[sel.value]

        pcall(vim.api.nvim_win_close, ab.visible, true)
        pcall(vim.api.nvim_win_close, j.winnr, true)

        local s = ''

        local status = j:sync_read {
            inc = 10;
            timeout = 10;
            tries = 10;
        }

        if status.stderr then
            s = s .. "STDERR:\n" .. status.stderr[1]
        end

        if status.stdout then
            if #s == 0 then
                s = "STDOUT:\n" .. status.stdout[1]
            else
                s = "\n\nSTDOUT:\n" .. status.stdout[1]
            end
        end

        if #s > 0 then
            local job_buffer = b.new(false)
            j.buffer = job_buffer
            j.buffer:write(false, s)
            ab.visible = j.buffer:split(d, win_opts)
            self.winnr = ab.visible 
        end
    end
        
    ts.new({
        title = 'Select output buffer for command';

        results = filter(function (kv)
            local fn, j = unpack(kv)
            if not j.winnr ~= ab.visible then return fn end
            pcall(vim.api.nvim_win_close, j.winnr)
            vim.api.nvim_win_close(j.winnr)
            return false
        end, items(self.jobs));

        mappings = get_results;
    }):find()
end

return ab
