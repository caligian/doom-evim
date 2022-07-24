local b = dofile('../../buffers/init.lua')
local kbd = require('core.kbd')
local a = dofile('../spawn.lua')
local ts = dofile('../../telescope/init.lua')
local ab = class('doom-async-buffer-utils')

ab.status = {}

function ab:__init(ft, cmd)
    self.cmd = cmd
    self.filetype = ft
    self.jobs = {}
end

function ab.new(opts)
    claim.table(opts)

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
    claim.table(opts)

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

function ab:show_output(opts)
    claim.table(opts)
    opts = opts or {}
    opts.direction = opts.direction or opts.d or 's'
    opts.opts = opts.opts or {}
    opts.input = opts.input =~ false or opts.input ~= nil and opts.input or false
    self:cleanup()

    local function get_results(d, sel)
        local name = sel.value
        local j = self.jobs[name]
        local s = ''
        local status = {}
        local has_stderr = j.stderr_output and #j.stderr_output.data ~= 0 
        local has_stdout = j.stdout_output and #j.stdout_output.data ~= 0 

        pcall(vim.api.nvim_win_close, ab.visible, true)
        pcall(vim.api.nvim_win_close, j.winnr, true)

        if not has_stderr and not has_stdout then
            assoc(j, 'sync_opts', {inc=10; timeout=100; tries=5, current_try=0})

            local timeout = j.sync_opts.timeout
            local inc = j.sync_opts.inc
            local tries = j.sync_opts.tries

            if input then
                timeout, inc, tries = unpack(gets('%', false, {
                    {'Timeout in ms', '100'};
                    {'Increment time in ms', '100'};
                    {'Number of tries', '5'}
                }))

                j.sync_opts.timeout = timeout
                j.sync_opts.inc = inc
                j.sync_opts.tries = tries
            end

            status = j:sync_read {
                inc = j.sync_opts.inc;
                timeout = j.sync_opts.timeout;
                tries = j.sync_opts.tries;
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
            opts.opts.force_resize = true
            ab.visible = j.buffer:split(d, opts.opts)
            self.winnr = ab.visible 
        else
            local i = gets('%', false, {'No output was found. Retry? (Press enter for no)'})
            if i == false then return end
            get_results(d, sel)
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

        mappings = {
            lpartial(get_results, opts.direction);

            -- Rerun the job
            {'n', 'r', function (sel)
                local j = self.jobs[sel.value]
                j:restart(true)
                get_results(opts.direction, sel)
            end, 'Restart job and get results'};

            {'n', 's', partial(get_results, 's'), 'Show output in split'};
            {'n', 'v', partial(get_results, 'v'), 'Show output in vsplit'};
            {'n', 'f', partial(get_results, 'f'), 'Show output in vsplit'};
            {'n', 't', partial(get_results, 't'), 'Show output in a new tab'};

            {'n', 'd', function (sel)
                local j = self.jobs[sel.value]
                to_stderr('Deleting job for buffer: ' .. j.name)
                if j then j:kill() end
                self.jobs[sel.value] = nil
            end, 'Delete job'};
        };
    }):find()
end

return ab
