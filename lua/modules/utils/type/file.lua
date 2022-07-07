-- local class = require('modules.utils.class')
local class = dofile('../class.lua')
local yaml = require('yaml')
local common = require('modules.utils.type.common')
local path = require('path')
local fl = {}
local m = {}

local function slurp(fh)
    fh = fh or false
    assert(fh, 'No file handle provided')

    return fh:read('*a')
end

function m.open(self, force)
    local status = io.type(self.handle)

    if force and status then
        if status == 'file' then
            self.handle:close()
        end
        self.handle = false
    elseif status == 'file' then
        return self.handle
    end

    local fh = io.open(self.filename, self.mode)
    if self.filename == 0 then
        fh = self.handle
    end

    if not fh then
        error('Could not open file handle for filename: ' .. self.filename)
    end

    self.handle = fh

    return self.handle
end

function m.write(self, s, how)
    if not self.handle then
        return false
    end

    assert(s)
    assert(self.mode:match('w') or self.mode:match('r+'), 'File ' .. self.filename .. ' has not been in write mode')

    -- If eval
    if how:match('y') then
        self.handle:write(yaml.dump(s))
    elseif how:match('j') then
        self.handle:write(vim.fn.json_encode(s))
    elseif how:match('lua') then
        if type(s) == 'string' then
            self.handle:write(s)
        else
            self.handle:write(vim.inspect(s))
        end
    else
        self.handle:write(s)
    end

    return true
end

function m.close(self)
    local status = io.type(self.handle)

    if status == 'file' then
        self.handle:close()
    elseif not status then
        return false
    end

    self.handle = false
    return true
end

function m.read(self, how)
    if not self.handle then
        return false
    end

    assert(self.mode:match('r'), 'File has not been opened in read mode')

    local _how = how or '*a'
    if how:match('[yj]') or how:match('lua') then
        _how = '*a'
    end

    local s = self.handle:read(_how)
    local rest = nil

    if how:match('y') then
        s = yaml.load(s)
    elseif how:match('j') then
        s = vim.fn.json_decode(s)
    elseif how:match('lua') then
        s, rest = load(s)
    end

    return s, rest
end

function m.flush(self)
    if not self.handle then
        return false
    end

    io.flush()
    return true
end

function m.iterread(self)
    if not self.handle then
        return false
    end

    assert(self.mode:match('r'), 'File has not been opened in read mode')

    local state = false
    return function ()
        if self.handle then
            state = self.handle:read()
            return state
        end
    end, self.handle or false, state
end

function m.seek(self, whence, offset)
    if not self.handle then
        return false
    end

    self.handle:seek(whence, offset)
    return true
end

function m.call(self, f, ...)
    if self.handle then
        return f(self.handle, ...)
    end

    return false
end

-- This method will reopen the file!
function fl.spit(filename, s, opts)
    assert(filename)
    assert(s)

    local fh = fl.new(filename, 'w')
    fh:open('*a')
    fh:write(s, opts)
    fh:close()

    return true
end

function fl.slurp(filename, opts)
    local fh = fl.new(filename, 'r')
    local s = fh:read('*a', opts)
    fh:close()

    return s
end

function fl.jslurp(filename)
    return fl.slurp(filename, 'j')
end

function fl.jspit(filename, s)
    return fl.spit(filename, s, 'j')
end

function fl.yslurp(filename)
    return fl.slurp(filename, 'y')
end

function fl.yspit(filename, s)
    return fl.spit(filename, s, 'y')
end

function fl.dump(filename, s)
    assert(s)

    s = type(s) ~= 'string' and vim.inspect(s) or s
    return fl.spit(filename, s)
end

function fl.new(filename, mode)
    local handle = false
    if filename == false then
        filename = 0
        mode = 'r+'
        handle = io.tmpfile()
    else
        mode = mode or 'r'
        assert(type(filename) == 'string')

        if mode == 'r' or mode == 'r+' then
            assert(path.exists(filename))
        end
    end

    local cls = class.new('file', {filename=filename, mode=mode, handle=handle})
    class.delegate(cls, m)

    return cls
end

return fl
