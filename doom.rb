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
    puts 'Please ensure that you have installed lua 5.1 on your system'
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
    @user_files.map { |i| `cp vdoomd/#{i} #{@user_dir}/` unless File.exist? "#{@user_dir}/#{i}" }
  end

  def install_fonts
    font_install_path = "#{ENV['HOME']}/.local/fonts"
    doom_fonts_dir = "#{@main_config_dir}/misc/fonts"

    Dir.chdir doom_fonts_dir

    Dir
      .children('.')
      .select { |i| i if i =~ /zip$/ }
      .map { |font| `unzip #{font}` }

    `find -name '*tf' -exec cp {} #{font_install_path}/ \\;`
    `fc-cache -vfr`

    puts 'Please restart your shell to load the fonts.'
  end

  def bootstrap
    package_dest = "#{ENV['HOME']}/.local/share/nvim/site/pack/packer/start"
    `mkdir -p '#{package_dest}' &>/dev/null`
    `git clone --depth 1 https://github.com/wbthomason/packer.nvim #{package_dest}/packer.nvim`
    `git clone https://github.com/Olical/aniseed #{package_dest}/aniseed`
    `git clone https://github.com/Olical/conjure #{package_dest}/conjure`
    `git clone https://github.com/bakpakin/fennel.vim #{package_dest}/fennel.vim`
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
  puts <<"EndString"
  $0: A utility script for first-time users.

  Commands:
  bootstrap         Installs essentials packages required by doom
  setup-lua         Install the required luarocks
  make-user-fs      Make ~/.vdoom.d/ and insert sample files in it
  install-fonts     Install several fonts to ~/.local/share/fonts
  setup-all         Do all of the above
EndString
else
  puts "Invalid command passed: #{args}"
end
