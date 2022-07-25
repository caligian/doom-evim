local utils = {}

function utils.func2ref(f, style)
    claim(f, 'string', 'callable')
    claim.opt_string(style)

    style = style or 'call'

    if str_p(f) then
        return f
    else
        if match(style, '^i') then
            return #Doom.au.refs
        elseif match(style, '^k') then
            return sprintf(':lua Doom.au.refs[%d]()<CR>', #Doom.au.refs)
        elseif match(style, '^c') then
            return sprintf(':lua Doom.au.refs[%d]()', #Doom.au.refs)
        else
            return sprintf('Doom.au.refs[%d]', #Doom.au.refs)
        end
    end
end

function utils.register(f, style)
    assoc(Doom.au, 'refs', {})
    if callable(f) then push(Doom.au.refs, f) end
    return utils.func2ref(f, style)
end

return utils
