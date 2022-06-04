local class = require('classy')
local sorters = require('telescope.sorters')
local finders = require('telescope.finders')
local actions = require('telescope.actions')
local action_state = require('telescope.actions.state')
local pickers = require('telescope.pickers')
local config = require('telescope.config').values
local ivy_theme = require('telescope.themes').get_ivy({
    layout_config = {height=0.37}
})

assert(packer_plugins['telescope.nvim'], 'No telescope installation found')

-- How entry is parsed
-- Either {value => value, display => value.display, ordinal => value.ordinal}
-- Or     {value => value[1], display => value.display, ordinal => value[1]}
-- Or     {value => value[1], display => value[2], ordinal => value.ordinal}
-- Or     {value => value[1], display => value[2], ordinal => value[3]}
-- Or     {value => value[1], display => value[2], ordinal => value[2]}
-- Or     {value => value, display => value, ordinal => value}
local function default_entry_maker(entry)
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
    oblige(title, 'No prompt title provided')
    oblige(results, 'No results provided')
    assert(mappings, 'Need at least one mapping')

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
        entry_maker = default_entry_maker
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

            assert(callable(default_action), 'Default action is mapped to <CR>. You only have to pass a callable for the first mapping')

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

return to_callable(new_picker)
