local telescope = require('telescope')
local sorters = require('telescope.sorters')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local transform_mod = require("telescope.actions.mt").transform_mod
local pickers = require('telescope.pickers')
local config = require('telescope.config').values
local ts = class('doom-telescope')
local ex = require('core.telescope.exception')

ts.defaults = assoc(Doom, {'telescope', 'defaults'}, {})
ts.defaults.opts = require('telescope.themes').get_ivy({layout_config={height=0.37}})
ts.defaults.opts.borderchars.prompt = { "", " ", " ", " ", " ", " ", " ", " " }
ts.defaults.opts.previewer = false
ts.defaults.opts.sorter = sorters.get_generic_fuzzy_sorter()
ts.defaults.opts.disable_devicons = true
update(Doom.telescope.defaults, ts.defaults)

-- How entry is parsed
-- Either {value => value, display => value.display, ordinal => value.ordinal}
-- Or     {value => value[1], display => value.display, ordinal => value[1]}
-- Or     {value => value[1], display => value[2], ordinal => value.ordinal}
-- Or     {value => value[1], display => value[2], ordinal => value[3]}
-- Or     {value => value[1], display => value[2], ordinal => value[2]}
-- Or     {value => value, display => value, ordinal => value}
function ts.entry_maker(entry)
    assert_type(entry, 'table', 'string')
    local t = {}

    if not table_p(entry) then
        return {value=entry, display=entry, ordinal=entry}
    end

    t.value = entry.value or entry[1]
    t.ordinal = entry.ordinal
    t.display = entry.display

    if not t.display then
        if #entry > 1 then 
            t.display = entry[2] 
        else
            t.display = entry[1]
        end
    end

    if not t.ordinal then
        if #entry > 1 then
            t.ordinal = entry[2]
        elseif #entry > 2 then
            t.ordinal = entry[3]
        else
            t.ordinal = entry[1]
        end
    end

    return t
end

function ts.new(opts, global_opts)
    assert(opts, 'No args given')
    assert_t(opts)
    assert_t(global_opts)

    global_opts = global_opts or ts.defaults.opts
    local title, results, mappings, entry_maker, sorter
    title = opts.title
    results = opts.results
    mappings = opts.mappings
    entry_maker = opts.entry_maker
    sorter = opts.sorter
    results = opts.results
    opts = merge(ts.defaults.opts, opts)
    sorter = sorter or 'fzy_index'
    entry_maker = opts.entry_maker or ts.entry_maker
    local picker = require('telescope.pickers')
    local telescope = require('telescope')

    assert(title, ex.picker.missing_title())
    assert(results, ex.picker.missing_results())
    assert(mappings, ex.picker.missing_mappings())

    assert_type(sorter, 'callable', 'boolean', 'string')
    assert_callable(opts.entry_maker)
    assert_s(title)
    assert_t(results)
    assert_type(mappings, 'callable', 'table')

    if sorter and str_p(sorter) then
        sorter = strip(sorter)
        if sorter:match('^generic_fzy') then
            sorter = sorters.get_generic_fuzzy_sorter()
        elseif sorter:match('^fzy_file') then
            sorter = sorters.get_fuzzy_file()
        elseif sorter:match('^fzy_index') then
            sorter = sorters.fuzzy_with_index_bias()
        elseif sorter:match('^highlighter') then
            sorter = sorters.highlighter_only()
        elseif sorter:match('^fzy') then
            sorter = sorters.get_fzy_sorter()
        end
    end

    -- Currently callable results are not working
    if callable(results) then
        results = finders.new_job(results, entry_maker)
    elseif table_p(results) then
        results = finders.new_table({results=results, entry_maker=entry_maker})
    elseif str_p(results) then
        results = finders.new_oneshot_job({results, entry_maker=entry_maker})
    end

    mappings = to_list(mappings)

    local args = {
        prompt_title = title,
        finder = results,
        sorter = sorter,
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local f = mappings[1]
                if table_p(f) then f = f[3] end
                actions.close(prompt_bufnr)
                local sel = action_state.get_selected_entry()
                f(sel)

                return true
            end)

            for i=2,#mappings do
                local mode, keys, f, doc, transform = unpack(mappings[i])
                transform = transfrom == nil and false

                assert(mode)
                assert(keys)
                assert(f)
                assert(doc)

                assert_s(mode)
                assert_s(keys)
                assert_s(doc)
                assert_callable(f)

                local _action = function()
                    local entry = action_state.get_selected_entry()
                    action_state.get_current_picker(prompt_bufnr)
                    actions.close(prompt_bufnr)
                    mappings[index][3](entry, bufnr)
                end

                local final_action = false

                if transform then
                    final_action = transform_mod({_action})
                else
                    final_action = _action
                end

                map(mode, keys, final_action)
            end

            return true
        end
    }

    return pickers.new(global_opts or {}, args)
end

return ts
