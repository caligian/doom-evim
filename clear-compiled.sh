#!/bin/bash

ls ~/.config/nvim/lua | grep -v modeline | grep -v nvim_cmp_setup | grep -v fennel | xargs -i{} -d$'\n' rm ~/.config/nvim/lua/{}
