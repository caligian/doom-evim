local class = require('modules.utils.class')
local yaml = require('yaml')
local common = require('modules.utils.type.common')
local path = require('path')
local fl = {}
local m = {}

local function get_status(handle) 
    local t = io.type(handle)
    if t == 'closed file' then
        return 0
    elseif t == 'file' then
        return 1
    end

    return false
end

local function slurp(fh)
    fh = fh or false
    assert(fh, 'No file handle provided')

    return fh:read('*a')
end

function m.open(self, force)
    local status = get_status(self.handle)

    if force and status == 1 then
        self.handle:close()
        self.handle = false
    elseif status == 1 then
        return self.handle
    end

    local fh = io.open(self.filename, self.mode)
    if not fh then
        error('Could not open file handle for filename: ' .. self.filename)
    end
    if self.filename == 0 then
        fh = self.handle
    end

    self.handle = fh

    return self.handle
end

function m.write(self, s, how)
    if get_status(self.handle) ~= 1 then
        return false
    end

    assert(s)
    assert(self.mode:match('wa') or self.mode:match('r+'), 'File ' .. self.filename .. ' has not been in write mode')

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
    if get_status(self.handle) ~= 1 then
        return false
    end

    assert(self.mode:match('r'), 'File has not been opened in read mode')

    how = how or '*a'
    local s = false
    if how:match('y') then
        s = yaml.load(self.handle:read('*a'))
    elseif how:match('j') then
        s = vim.fn.json_decode(self.handle:read('*a'))
    elseif how:match('lua') then
        s = load(self.handle:read('*a'))
    else
        s = self.handle:read('*a')
    end

    return s
end

function m.flush(self)
    if get_status(self.handle) ~= 1 then
        return false
    end

    io.flush()
    return true
end

function m.iterread(self)
    if get_status(self.handle) ~= 1 then
        return false
    end

    assert(self.mode:match('r'), 'File has not been opened in read mode')

    local state = self.handle:read()
    return function ()
        if state then
            state = self.handle:read()
            return state
        end
    end, self.handle, state
end

function m.seek(self, whence, offset)
    if get_status(self.handle) ~= 1 then
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
function fl.spit(filename, s, how)
    assert(filename)
    assert(s)

    local fh = fl.new(filename, 'w')
    fh:open('*a')
    fh:write(s, how)
    fh:close()

    return true
end

function fl.slurp(filename, how)
    local fh = fl.new(filename, 'r')

    fh:open()
    local s = fh:read('*a', how)
    fh:close()

    return s
end

function fl.jslurp(filename)
    assert(filename)

    return fl.slurp(filename, 'j')
end

function fl.jspit(filename, s)
    assert(filename)
    assert(s)

    return fl.spit(filename, s, 'j')
end

function fl.yslurp(filename)
    assert(filename)
    assert(s)

    return fl.slurp(filename, 'y')
end

function fl.yspit(filename, s)
    assert(filename)
    assert(s)

    return fl.spit(filename, s, 'y')
end

function fl.dump(filename, s)
    assert(filename)
    assert(s)

    s = type(s) ~= 'string' and vim.inspect(s) or s
    return fl.spit(filename, s)
end

function fl.new(filename, mode)
    if filename == false then
        mode = 'r+'
        filename = os.tmpname()
    else
        mode = mode or 'r'
        assert(type(filename) == 'string')

        if mode == 'r' or mode == 'r+' then
            assert(path.exists(filename))
        end
    end

    local cls = class.new('file', {
        filename = filename,
        mode = mode, 
        handle = false,
    })

    class.delegate(cls, m)
    local old_delete = m.close

    if filename:match('/tmp') then
        class.delegate(cls, {
            delete = function (self)
                vim.fn.system('rm ' .. self.filename)
            end;

            close = function (self)
                old_delete(self) 
                self:delete()
            end
        })
    end

    return cls
end

return fl
