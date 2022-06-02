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

-- @tparam title string Title of the Telescope buffer
-- @tparam results table[string]|function]|table[table[string]] 
-- @tparam[optional] entry_maker function 
-- @tparam[optional] sorter string
-- @tparam default_mapping function
-- @tparam mappings table[string,string,function]
return to_callable(function (title, results, entry_maker, sorter, default_mapping, mappings, opts)
    opts = opts or {}
    opts = merge(ivy_theme, opts)
    oblige(title, 'No prompt title provided')
    oblige(results, 'No results provided')
    assert(default_mapping, 'No default keymapping provided for picker')
    assert(callable(default_mapping), 'default_mapping should be a callable callback')

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
        entry_maker = function(e)
            if str_p(e) then
                return {value=e, display=e, ordinal=e}
            elseif table_p(e) then
                if #e == 1 then 
                    return {value=e, display=e[1], ordinal=e[1]}
                elseif #e >= 2 then
                    return {value=e, display=e[1], ordinal=e[2]}
                end
            end
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

    return pickers.new(opts, {
        prompt_title = title,
        finder = results,
        sorter = sorter,

        attach_mappings = function(bufnr, bind)
            actions.select_default:replace(function()
                actions.close(bufnr)
                selection = action_state.get_selected_entry()
                default_mapping(selection.value)
            end)

            if mappings then
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
end)
