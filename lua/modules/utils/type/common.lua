local tu = require('modules.utils.table')
local u = require('modules.utils.common')
local class = require('modules.utils.class')
local methods = {}

methods.to_stderr = u.to_stderr
methods.dump = u.dump
methods.inspect = u.inspect
methods.to_arr = u.to_list
methods.to_list = u.to_list
methods.to_a = u.to_list
methods.ydump = u.ydump
methods.jdump = u.jdump
methods.deepcopy = u.deepcopy
methods.copy = u.copy
methods.chomp = u.chomp
methods.sprintf = function(obj, fmt) return u.sprintf(fmt, obj) end
methods.printf = function(obj, fmt) return u.printf(fmt, obj) end
methods.echo = function(obj, fmt) return u.echo(fmt, obj) end
methods.call = function(obj, func) return func(obj) end
methods.spit = function(obj, dst, mode) u.spit(dst, dump(obj)) end
methods.yspit = function(obj, dst) u.yspit(dst, obj) end
methods.jspit = function(obj, dst) u.jspit(dst, obj) end

return methods
