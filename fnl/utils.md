
# utils.md: Documentation

This file is the heart and soul of doom. It contains all the required functions to handle the abstraction that doom creates over vim.

Although the documentation of the file is incomplete, you can still go through the code at your leisure in order to get a comprehensive understanding of this module. However, I will only mention the ones the user can use.

## Globals defined
- `map-help-groups` Form: {:prefix {:key "Group description"}}. This is a table that is used for which-key to obtain description for prefixes. You can always append to this dictionary as and when you want. `Prefix` is either `leader` or `localleader`.
- `lambdas` Form: `[f, g, h, i, ...]`. Contains functions indexed at n+1. This is used by `register` to get command strings.

## Functions
Functions can be accessed by `doom.utils.<function>`

### Viewers
- `dump` Dump objects. Uses `fennel.view` instead of `vim.inspect`. Returns: `nil` 

### Dictionary and List
- `keys` Get all the keys in a table which are not nil-valued. Returns: `list`
- `values` Get all the values in a table. Returns: `list` 
- `vec` Convert a generator to a list. Accepts one param that is the generator in question. Returns: `list`.
- `first` Returns the first element of a list. Returns: `nil` or `any`
- `rest`  Returns everything except the first one. Returns: `nil` or `any` 
- `ifirst` Same as `first` but for generator objects.
- `irest` Same as `rest` but for generator objects.

### Misc
- `register` Get a command string that can be used in keybindings. Accepts one parameters: function. Returns: `string`
- `consider-os` Accept a table of key-value in the form: `{:os callback}`. Whichever key gets an output of `1` from `vim.fn.has`, that key's `callback` is returned. Returns: `function`

### Path
- `join_path`. Accepts any number of params. All of them will be joined with '\\' on windows and '/' otherwise. Returns: `string`
- `path-exists` Works like `vim.fn.glob`. Accepts one param: `path`. Returns `list[string]` that lists the directory or false
- `list-dir` List directory. Accepts one param that is used as the path. Returns: `list[string] or false`

Please `(require "path")` instead. These are half-baked functions at best.

### Terminal 
- `split-term-and` Accepts 1 mandatory param and 2 optional param. First param is the command that would be run in the terminal that will be split beside your buffer. Second param is the direction of split (`sp` or `vsp`). Third parameter if true provides a string of the command instead of actually splitting the buffer. This is useful to use with keybindings. Returns: `nil` or `string`

### Commands
- `exec` A sort of an alias to `vim.cmd`. Accepts n params. First one is a template string that can be used with `string.format` and the rest of the params should be strings substituted inside the template. Returns: `nil`.

### Strings
- `grep`. Accepts 2 params. First one is the string to match and second is any PCRE2 regex. Returns: `boolean`
- `split`. Accepts 2 params. First one is the string to be split and second one should be PCRE2 regex. By default, the splitting pattern used will be `[^\n\r]+`. Returns: `list`
- `sed` Accepts 3 parameters. First one is the string to sed. Second one is a table containing replacement patterns. Third one is the table containing substitute patterns. Return string will contain all/any replacements carried out. Returns: `string`

### Editing
- `promote-indent` and `demote-indent` Accept an optional param as line number to indent. If no param is provided, current line will be indented or deindented. `vim.bo.shiftwidth` is used to determine the value of spaces inserted. Returns: `nil`



