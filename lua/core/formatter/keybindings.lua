local formatter = require "core.formatter"

kbd.new("formatbuffer", "n", "<leader>bf", formatter.format_buffer, false, "Format current buffer"):enable()
