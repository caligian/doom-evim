local format = {}

function format.format_buffer(ft, bufnr)
    ft = vim.bo.filetype or ft
    bufnr = bufnr or vim.fn.bufnr()

    claim.number(bufnr)
    claim.string(ft)

    local f = assoc(Doom.langs, {ft, "format"})
    if not f then
        error("No formatter defined for current buffer ft: " .. ft)
    end

    claim(f, "string", "table")

    local manual = false
    local cmd = false

    if table_p(f) then
        manual = f.manual
        cmd = first(f)
    else
        cmd = f
    end

    if manual then
        local s = system(cmd .. " " .. vim.fn.expand("%:p"))
        vim.api.nvim_buf_set_lines(0, 0, -1, false, s)
    else
        system(cmd .. " " .. vim.fn.expand("%:p"))
    end
end

function format.enable_autoformat()
end
