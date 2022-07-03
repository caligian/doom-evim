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

function ab:show_output(d, win_opts, input)
    self:cleanup()

    local function get_results(sel)
        local name = sel.value
        local j = self.jobs[name]
        local s = ''
        local status = {}
        local has_stderr = j.stderr_output and #j.stderr_output.data ~= 0 
        local has_stdout = j.stdout_output and #j.stdout_output.data ~= 0 

        pcall(vim.api.nvim_win_close, ab.visible, true)
        pcall(vim.api.nvim_win_close, j.winnr, true)

        if not has_stderr and not has_stdout then
            assoc(j, 'sync_opts', {inc=10; timeout=100; tries=5})
            local timeout = 'Timeout: ' .. j.sync_opts.timeout .. 'ms'
            local inc = 'Increment by: ' .. j.sync_opts.inc .. 'ms'
            local tries = 'Try N times: ' .. j.sync_opts.tries

            if input then
                input = gets('%', {
                    {"Current values:\nTimeout: %dms"}
                })
            end

            status = j:sync_read {
                inc = 10;
                timeout = 1000;
                tries = 10;
            }
        end

        if has_stdout then
            local stdout = status.stdout or j.stdout_output.data
            if #s == 0 then
                s = "STDOUT:\n" .. stdout[1]
            else
                s = "\n\nSTDOUT:\n" .. stdout[1]
            end

            s = s .. "STDERR:\n" .. stdout[1]
        end

        if has_stderr then
            local stderr = status.stderr or j.stderr_output.data
            s = s .. "STDERR:\n" .. stderr[1]
        end

        if #s > 0 then
            local job_buffer = b.new(name .. '_output', true)
            j.buffer = job_buffer
            j.buffer:write(false, s)
            d = d or 's'
            win_opts = win_opts or {}
            win_opts.force_resize = true
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

local test = ab.new()
test:add_buffer()
test:show_output()

return ab
