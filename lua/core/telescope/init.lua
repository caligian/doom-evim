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

-- @tparam title string Title of the Telescope buffer
-- @tparam results table[string]|function]|table[table[string]] 
-- @tparam[optional] entry_maker function 
-- @tparam[optional] sorter string
-- @tparam mappings table[string,string,function]
function ts:__init(title, results, entry_maker, sorter, mappings, opts)
    assert(title, ex.picker.missing_title())
    assert(results, ex.picker.missing_results())
    assert(mappings, ex.picker.missing_mappings())

    local picker = require('telescope.pickers')
    local telescope = require('telescope')

    assert_s(title)
    assert_t(results)
    assert_type(mappings, 'callable', 'table')
    assert_t(opts)

    local ivy_theme = require('telescope.themes').get_ivy({
        layout_config = {height=0.37}
    })
    opts = opts or {}
    merge(opts, ivy_theme)
    mappings = to_list(mappings)
    sorter = sorter or 'fzy_index'
    sorter = strip(sorter)

    inspect(opts)

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
        assert_callable(entry_maker)
    else 
        entry_maker = ts.entry_maker
    end

    self.sorter = sorter
    self.entry_maker = entry_maker
    self.mappings = mappings
    self.opts = opts
    self.results = results
    self.title = title
end

function ts:new(opts)
    assert_t(opts)

    opts = opts or self.opts

    -- Currently callable results are not working
    if callable(self.results) then
        self.results = finders.new_job(self.results, entry_maker)
    elseif table_p(self.results) then
        self.results = finders.new_table({results=self.results, entry_maker=entry_maker})
    elseif str_p(self.results) then
        self.results = finders.new_oneshot_job({self.results, entry_maker=entry_maker})
    end

    opts.mappings = opts.mappings or self.mappings

    self.picker = pickers.new(opts, {
        prompt_title = self.title,
        finder = self.results,
        sorter = self.sorter,
        attach_mappings = function(prompt_bufnr, map)
            actions.select_default:replace(function()
                local f = opts.mappings[1]
                if table_p(f) then f = f[3] end
                actions.close(prompt_bufnr)
                local sel = action_state.get_selected_entry()
                f(sel)

                return true
            end)

            if #opts.mappings < 2 then return true end

            shift(opts.mappings)

            for index, k in ipairs(opts.mappings) do
                local mode, keys, f, doc, transform = unpack(k)
                print(mode, keys, f, doc, transform)
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
                    opts.mappings[index][3](entry, bufnr)
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
    })

    return self.picker
end

function ts:update(title, results, entry_maker, sorter, mappings, opts)
    self.title = title
    self.results = results
    self.entry_maker = entry_maker
    self.sorter = sorter
    self.mappings = mappings
    self.opts = opts
    self.previous_picker = self.picker

    return self:new()
end

function ts:find(opts)
    if not self.picker then self:new(opts) end
    assert(self.picker)
    self.picker:find()
end

return ts
