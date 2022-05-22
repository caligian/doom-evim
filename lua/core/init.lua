-- Initialize all the packages
local pkgs = require('core.pkgs')
local p = pkgs()
p:startup_packer()
p:init_essential_packages()

-- Globalize logger
require('core.log')
