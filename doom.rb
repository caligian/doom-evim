#!/usr/bin/ruby
# frozen_string_literal: true

class SetupDoom
  def initialize
    @main_config_dir = "#{ENV['HOME']}/.config/nvim"
    @user_dir = "#{ENV['HOME']}/.vdoom.d"
    @user_files = ['user-init.lua', 'user-packages.lua']
    @user_other_dirs = %w[lua fnl]
  end

  def setup_lua
    puts 'Installing: set-lua, lualogging, lpath, luafun'
    `luarocks --lua-version 5.1 --local install set-lua`
    `luarocks --lua-version 5.1 --local install lualogging`
    `luarocks --lua-version 5.1 --local install lpath`
    `luarocks --lua-version 5.1 --local install fun`
    puts 'Please reopen your shell in order to use the lua packages.'
  end

  def make_user_fs
    Dir.mkdir @user_dir unless Dir.exist? @user_dir
    @user_other_dirs.map { |i| Dir.mkdir "#{@user_dir}/#{i}" unless Dir.exist? "#{@user_dir}/#{i}" }
    @user_files.map { |i| `cp sample-user-configs/#{i} #{@user_dir}/` unless File.exist? "#{@user_dir}/#{i}" }
  end

  def install_fonts
    font_install_path = "#{ENV['HOME']}/.local/fonts"
    doom_fonts_dir = "#{@main_config_dir}/misc/fonts"

    Dir.chdir doom_fonts_dir

    available_fonts = Dir.glob '*zip'

    available_fonts.map do |font|
      fonts = `unzip -l #{font}`.split /\n/
      fonts = fonts.select {|i| i.match /^\s*[0-9]/}
      fonts = fonts.map {|f| _f = f.split /\s+/; %{"#{_f[4..].join ' '}"} }
      fonts = fonts.select {|f| f.match /(ttf|otf)"$/ }
      `unzip -o #{font}`
      fonts.each {|f| `mv #{f} ~/.local/share/fonts/`}
      `fc-cache -fv`
    end
   
    puts 'Please restart your shell to load the fonts.'
  end

  def bootstrap
    package_dest = "#{ENV['HOME']}/.local/share/nvim/site/pack/packer/start"
    `mkdir -p '#{package_dest}' &>/dev/null`
    `git clone --depth 1 https://github.com/wbthomason/packer.nvim #{package_dest}/packer.nvim`

    # These are the bootstrap packages!
    %w[Olical/aniseed Olical/conjure bakpakin/fennel.vim nvim-lua/plenary.nvim svermeulen/vimpeccable folke/which-key.nvim kreskij/Repeatable.vim guns/vim-sexp folke/persistence.nvim].each do |repo|
      `git clone https://github.com/#{repo} #{package_dest}/#{repo.match(%r{/([^$]+)})[1]}`
    end
  end
end

args = ARGV.pop

if args =~ /setup-all/
  c = SetupDoom.new
  c.setup_lua
  c.make_user_fs
  c.install_fonts
  c.bootstrap
elsif args =~ /bootstrap/
  SetupDoom.new.bootstrap
elsif args =~ /setup-lua/
  SetupDoom.new.setup_lua
elsif args =~ /install-fonts/
  SetupDoom.new.install_fonts
elsif args =~ /make-user-fs/
  SetupDoom.new.make_user_fs
elsif args =~ /help/
  puts <<"ENDSTRING"
  bootstrap         Installs essentials packages required by doom
  setup-lua         Install the required luarocks
  make-user-fs      Make ~/.vdoom.d/ and insert sample files in it
  install-fonts     Install several fonts to ~/.local/share/fonts
  setup-all         Do all of the above
ENDSTRING
elsif args == ''
  puts "No command passed. Pass `help` to see the commands."
else
  puts "Invalid command passed: #{args}"
end
