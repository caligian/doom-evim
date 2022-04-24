local Utils = require('core.doom-utils')

local a = {
    1,
    2,
    3,
    a = 1,
    b = 2,
}

print(#(Utils.keys(a)), #a)
