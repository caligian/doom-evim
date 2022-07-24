local sig = class('doom-async-signal')
local uv = vim.loop

sig.signals = {
    [1] = 'SIGHUP';
    ['SIGHUP'] = 1;

    [2] = 'SIGINT';
    ['SIGINT'] = 2;

    [3] = 'SIGQUIT';
    ['SIGQUIT'] = 3;

    [4] = 'SIGILL';
    ['SIGILL'] = 4;

    [5] = 'SIGTRAP';
    ['SIGTRAP'] = 5;

    [6] = 'SIGABRT';
    ['SIGABRT'] = 6;

    [7] = 'SIGBUS';
    ['SIGBUS'] = 7;

    [8] = 'SIGFPE';
    ['SIGFPE'] = 8;

    [9] = 'SIGKILL';
    ['SIGKILL'] = 9;

    [10] = 'SIGUSR1';
    ['SIGUSR1'] = 10;

    [11] = 'SIGSEGV';
    ['SIGSEGV'] = 11;

    [12] = 'SIGUSR2';
    ['SIGUSR2'] = 12;

    [13] = 'SIGPIPE';
    ['SIGPIPE'] = 13;

    [14] = 'SIGALRM';
    ['SIGALRM'] = 14;

    [15] = 'SIGTERM';
    ['SIGTERM'] = 15;

    [16] = 'SIGSTKFLT';
    ['SIGSTKFLT'] = 16;

    [17] = 'SIGCHLD';
    ['SIGCHLD'] = 17;

    [18] = 'SIGCONT';
    ['SIGCONT'] = 18;

    [19] = 'SIGSTOP';
    ['SIGSTOP'] = 19;

    [20] = 'SIGTSTP';
    ['SIGTSTP'] = 20;

    [21] = 'SIGTTIN';
    ['SIGTTIN'] = 21;

    [22] = 'SIGTTOU';
    ['SIGTTOU'] = 22;

    [23] = 'SIGURG';
    ['SIGURG'] = 23;

    [24] = 'SIGXCPU';
    ['SIGXCPU'] = 24;

    [25] = 'SIGXFSZ';
    ['SIGXFSZ'] = 25;

    [26] = 'SIGVTALRM';
    ['SIGVTALRM'] = 26;

    [27] = 'SIGPROF';
    ['SIGPROF'] = 27;

    [28] = 'SIGWINCH';
    ['SIGWINCH'] = 28;

    [29] = 'SIGIO';
    ['SIGIO'] = 29;

    [30] = 'SIGPWR';
    ['SIGPWR'] = 30;

    [31] = 'SIGSYS';
    ['SIGSYS'] = 31;

    [34] = 'SIGRTMIN';
    ['SIGRTMIN'] = 34;

    [35] = 'SIGRTMIN+1';
    ['SIGRTMIN+1'] = 35;

    [36] = 'SIGRTMIN+2';
    ['SIGRTMIN+2'] = 36;

    [37] = 'SIGRTMIN+3';
    ['SIGRTMIN+3'] = 37;

    [38] = 'SIGRTMIN+4';
    ['SIGRTMIN+4'] = 38;

    [39] = 'SIGRTMIN+5';
    ['SIGRTMIN+5'] = 39;

    [40] = 'SIGRTMIN+6';
    ['SIGRTMIN+6'] = 40;

    [41] = 'SIGRTMIN+7';
    ['SIGRTMIN+7'] = 41;

    [42] = 'SIGRTMIN+8';
    ['SIGRTMIN+8'] = 42;

    [43] = 'SIGRTMIN+9';
    ['SIGRTMIN+9'] = 43;

    [44] = 'SIGRTMIN+10';
    ['SIGRTMIN+10'] = 44;

    [45] = 'SIGRTMIN+11';
    ['SIGRTMIN+11'] = 45;

    [46] = 'SIGRTMIN+12';
    ['SIGRTMIN+12'] = 46;

    [47] = 'SIGRTMIN+13';
    ['SIGRTMIN+13'] = 47;

    [48] = 'SIGRTMIN+14';
    ['SIGRTMIN+14'] = 48;

    [49] = 'SIGRTMIN+15';
    ['SIGRTMIN+15'] = 49;

    [50] = 'SIGRTMAX-14';
    ['SIGRTMAX-14'] = 50;

    [51] = 'SIGRTMAX-13';
    ['SIGRTMAX-13'] = 51;

    [52] = 'SIGRTMAX-12';
    ['SIGRTMAX-12'] = 52;

    [53] = 'SIGRTMAX-11';
    ['SIGRTMAX-11'] = 53;

    [54] = 'SIGRTMAX-10';
    ['SIGRTMAX-10'] = 54;

    [55] = 'SIGRTMAX-9';
    ['SIGRTMAX-9'] = 55;

    [56] = 'SIGRTMAX-8';
    ['SIGRTMAX-8'] = 56;

    [57] = 'SIGRTMAX-7';
    ['SIGRTMAX-7'] = 57;

    [58] = 'SIGRTMAX-6';
    ['SIGRTMAX-6'] = 58;

    [59] = 'SIGRTMAX-5';
    ['SIGRTMAX-5'] = 59;

    [60] = 'SIGRTMAX-4';
    ['SIGRTMAX-4'] = 60;

    [61] = 'SIGRTMAX-3';
    ['SIGRTMAX-3'] = 61;

    [62] = 'SIGRTMAX-2';
    ['SIGRTMAX-2'] = 62;

    [63] = 'SIGRTMAX-1';
    ['SIGRTMAX-1'] = 63;

    [64] = 'SIGRTMAX';
    ['SIGRTMAX'] = 64;
}

function sig:__init(id, handle)
    self.id = id
    self.signal = uv.new_signal()
    self.handle = handle
    self.callbacks = {}
end

function sig.new(id, handle)
    assert(id)
    assert(handle)
    claim(id, 'number', 'string')
    assert(handle)

    id = sig.signals[id]
    assert(id, 'Invalid signal ID provided')

    return sig(id, handle)
end

function sig:add_callback(f)
    assert(f)
    claim.callable(f)

    push(self.callbacks, f)
end

function sig:add_callbacks(...)
    each(partial(self.add_callback, self), {...})
end

function sig:get_callback()
    assert(#self.callbacks > 0, 'No callbacks have been added yet')

    return function (exit_id)
        each(partial(c, exit_id), self.callbacks)
    end
end

function sig:start_oneshot()
    local exit = self.signal:start_oneshot(self.id, self:get_callback())
    return exit == 0
end

function sig:start()
    local exit = self.signal:start(self.id, self:get_callback())
    return exit == 0
end

function sig:stop()
    local exit = self.signal:stop()
    return exit == 0
end

return sig
