local utils = require('modules.utils.common')
local tutils = require('modules.utils.table')
local param = require('modules.utils.param')
local func = require('modules.utils.function')
local strutils = require('modules.utils.string')
local mod = require('modules.utils.module')
utils.globalize(utils)
utils.globalize(tutils)
utils.globalize(param)
utils.globalize(strutils)
utils.globalize(func)
utils.add_global(mod, 'mod')
