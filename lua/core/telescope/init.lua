local Telescope = {}
local TPickers = require('telescope.pickers')
local TFinders = require('telescope.finders')
local TConf = require('telescope.config').values
local TActions = require('telescope.actions')
local TActionState = require('telescope.actions.state')
local TIvy = require('telescope.themes').get_ivy()

function Telescope.new(opts)
    local defaultFunc = opts.hook
    local defaultFuncArgs = opts.hookArgs or {}
    local getter = opts.getter
    local getterArgs = opts.getterArgs or {}
    local pickerArgs = opts.pickerArgs or {}
    local promptTitle = opts.title or ""

    opts = opts or {}
    opts = vim.tbl_extend('force', opts, TIvy)

    assert(defaultFunc and getter)

    TPickers.new(pickerArgs, {
        prompt_title = promptTitle,

        finder = TFinders.new_table({results = getter(unpack(getterArgs))}),

        sorter = TConf.generic_sorter(pickerArgs),

        attach_mappings = function (bufnr, map)
            TActions.select_default:replace(function ()
                TActions.close(bufnr)
                local selection = TActionState.get_selected_entry()
                
                defaultFunc(selection, bufnr, map, unpack(defaultFuncArgs))
            end)

            return true
        end
    }):find()
end

return Telescope
