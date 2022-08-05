local color = {}

function color.get_highlight_colors(hi)
    local c = {}
    local t = slice(vim.split(vcmd(':hi ' .. hi), ' +'), 3)
    each(t, function (s)
        local a, hex = unpack(vim.split(s, '='))
        c[a] = hex or false
    end)

    return c
end

function color.hex2rgb(hex)
    hex = hex:gsub("#","")
    return tonumber("0x"..hex:sub(1,2)), tonumber("0x"..hex:sub(3,4)), tonumber("0x"..hex:sub(5,6))
end

-- Taken from https://github.com/iskolbin/lhsx/blob/master/hsx.lua
function color.rgb2hsv(r, g, b)
	local M, m = math.max( r, g, b ), math.min( r, g, b )
	local C = M - m
	local K = 1.0/(6.0 * C)
	local h = 0.0
	if C ~= 0.0 then
		if M == r then     h = ((g - b) * K) % 1.0
		elseif M == g then h = (b - r) * K + 1.0/3.0
		else               h = (r - g) * K + 2.0/3.0
		end
	end
	return h, M == 0.0 and 0.0 or C / M, M
end

function color.hsv2rgb(h, s, v)
	local C = v * s
	local m = v - C
	local r, g, b = m, m, m
	if h == h then
		local h_ = (h % 1.0) * 6
		local X = C * (1 - math.abs(h_ % 2 - 1))
		C, X = C + m, X + m
		if     h_ < 1 then r, g, b = C, X, m
		elseif h_ < 2 then r, g, b = X, C, m
		elseif h_ < 3 then r, g, b = m, C, X
		elseif h_ < 4 then r, g, b = m, X, C
		elseif h_ < 5 then r, g, b = X, m, C
		else               r, g, b = C, m, X
		end
	end
	return r, g, b
end

function color.darken(hex, darker_n)
    local result = "#"

    for s in hex:gmatch("[a-fA-F0-9][a-fA-F0-9]") do
        local bg_numeric_value = tonumber("0x" .. s) - darker_n

        if bg_numeric_value < 0 then
            bg_numeric_value = 0
        end

        if bg_numeric_value > 255 then
            bg_numeric_value = 255
        end

        result = result .. string.format("%2.2x", bg_numeric_value)
    end

    return result
end

function color.lighten(hex, lighten_n)
    return color.darken(hex, lighten_n * -1)
end

function color.get_luminance(hex)
    local r,g,b = color.hex2rgb(hex)
    local luminance = (r*0.2126) + (g*0.7152) + (b*0.0722)
    return luminance < (255/2)
end

return color
