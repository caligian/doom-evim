local sorters = require('telescope.sorters')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local config = require('telescope.config').values
local ivy_theme = require('telescope.themes').get_ivy({
    layout_config = {height=0.37}
})

local ts = class('doom-telescope')
ts.exception = require('core.telescope.exception')

assert(packer_plugins['telescope.nvim'], ts.exception.NO_TELESCOPE)

-- How entry is parsed
-- Either {value => value, display => value.display, ordinal => value.ordinal}
-- Or     {value => value[1], display => value.display, ordinal => value[1]}
-- Or     {value => value[1], display => value[2], ordinal => value.ordinal}
-- Or     {value => value[1], display => value[2], ordinal => value[3]}
-- Or     {value => value[1], display => value[2], ordinal => value[2]}
-- Or     {value => value, display => value, ordinal => value}
function ts.entry_maker(entry)
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

-- @tparam title string Title of the Telescope buffer
-- @tparam results table[string]|function]|table[table[string]] 
-- @tparam[optional] entry_maker function 
-- @tparam[optional] sorter string
-- @tparam mappings table[string,string,function]
local function new_picker (title, results, entry_maker, sorter, mappings, opts)
    assert(title, ts.exception.picker.MISSING_TITLE)
    assert(results, ts.exception.picker.MISSING_RESULTS)
    assert(mappings, ts.exception.picker.MISSING_MAPPINGS)

    opts = opts or {}
    opts = merge(ivy_theme, opts)
    mappings = to_list(mappings)
    sorter = sorter or 'fzy_index'
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

    if entry_maker then
        oblige(callable(entry_maker), 'Entry maker should be callable')
    else 
        entry_maker = ts.entry_maker
    end

    -- Currently callable results are not working
    if callable(results) then
        results = finders.new_job(results, entry_maker)
    elseif table_p(results) then
        results = finders.new_table({results=results, entry_maker=entry_maker})
    elseif str_p(results) then
        results = finders.new_oneshot_job({results, entry_maker=entry_maker})
    end

    return pickers.new(opts, {
        prompt_title = title,
        finder = results,
        sorter = sorter,

        attach_mappings = function(bufnr, bind)
            assert(#mappings >= 1, 'Need at least one mapping')

            local default_action = shift(mappings)

            assert(callable(default_action), 'Action should be a callable')

            actions.select_default:replace(function()
                actions.close(bufnr)
                selection = action_state.get_selected_entry()
                default_action(selection.value)
            end)

            if #mappings > 0 then
                map(function(m) 
                    assert(table_p(m))
                    assert(#m == 3, 'Require mode, keys and callback')

                    local mode, keys, f = unpack(m)
                    local _f = function()
                        actions.close(bufnr)
                        selection = action_state.get_selected_entry()
                        f(selection.value)
                    end
                    bind(mode, keys, _f)
                end, mappings)
            end

            return true
        end
    }):find()
end

function ts.from_picker(picker, title, sorter, mappings, opts)
    assert(picker, 'No telescope picker provided')
    assert(title, ts.exception.MISSING_TITLE)
    assert(mappings, ts.exception.MISSING_MAPPINGS)
    assert(str_p(picker), 'Invalid picker name provided')
    assert(table_p(mappings), 'Invalid mappings list provided')

    opts = opts or {}
    opts = merge(ivy_theme, opts)
    sorter = sorter or 'fzy_index'

    local new_picker = require('telescope')

    each(function(mode)
        local binding = mappings[mode]
        assert(table_p(binding), 'Invalid mapping provided. Need {keys, callback}')
        assert(#binding == 2, 'Need {keys, callback}')
    end, keys(mappings))

    return picker(opts, {
        prompt_title =  title,
        sorter = sorter,
        attach_mappings = function(bufnr, bind)
            assert(#mappings >= 1, 'Need at least one mapping')

            local default_action = shift(mappings)

            assert(callable(default_action), 'Action should be a callable')

            actions.select_default:replace(function()
                actions.close(bufnr)
                selection = action_state.get_selected_entry()
                default_action(selection.value)
            end)

            if #mappings > 0 then
                map(function(m) 
                    assert(table_p(m))
                    assert(#m == 3, 'Require mode, keys and callback')

                    local mode, keys, f = unpack(m)

                    bind(mode, keys, function()
                        actions.close(bufnr)
                        selection = action_state.get_selected_entry()
                        f(selection.value)
                    end)
                end, mappings)
            end

            return true
        end
    })
end

ts.from_picker(require('telescope.builtin').find_files, 'Madarchod', false, {function(selection) inspect(selection) end})

return ts
