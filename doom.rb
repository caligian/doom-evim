#!/usr/bin/ruby
# frozen_string_literal: true

class SetupDoom
  def initialize
    @main_config_dir = "#{ENV['HOME']}/.config/nvim"
    @user_dir = "#{ENV['HOME']}/.vdoom.d"
    @user_files = ['user-init.lua', 'user-packages.lua', 'user-specs.lua']
    @user_other_dirs = %w[lua fnl]

    @package_dest = "#{ENV['HOME']}/.local/share/nvim/site/pack/packer/start"
    @packages = {
      'gmist/vim-palette' => "662012963694e6bc5268765b809341d68373cf55",
      'Olical/aniseed' => 'bd19b2a86a3d4a0ee184412aa3edb7ed57025d56',
      'kreskij/Repeatable.vim' => 'ab536625ef25e423514105dd790cb8a8450ec88b',
      'folke/which-key.nvim' => '28d2bd129575b5e9ebddd88506601290bb2bb221',
      'svermeulen/vimpeccable' => 'bd19b2a86a3d4a0ee184412aa3edb7ed57025d56',
      'nvim-lua/plenary.nvim' => '563d9f6d083f0514548f2ac4ad1888326d0a1c66',
      'Olical/conjure' => '2717348d1a0687327f59880914fa260e4ad9c685',
      'bakpakin/fennel.vim' => '30b9beabad2c4f09b9b284caf5cd5666b6b4dc89',
    }
  end

  def get_repo_basename(repo)
    repo.match(%r{/([^$]+)})[1]
  end

  def clone_repo(repo)
    basename = get_repo_basename(repo)
    path = "#{@package_dest}/#{basename}"
    `git clone https://github.com/#{repo} #{path}`
  end

  def reset_repo(repo, commit)
    basename = get_repo_basename(repo)
    path = "#{@package_dest}/#{basename}"
    Dir.chdir path
    `git reset --hard #{commit}`
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

    `cp lua/default_packages.lua sample-user-configs/user-packages.lua`

    unless Dir.exist? "#{ENV['HOME']}/.local/share/nvim/user-snippets"
      `mkdir ~/.local/share/nvim/user-snippets`
      `cp user-snippets/*.json ~/.local/share/nvim/user-snippets/`
    end

    @user_files.map { |i| `cp sample-user-configs/#{i} #{@user_dir}/` unless File.exist? "#{@user_dir}/#{i}" }
  end

  def install_fonts
    doom_fonts_dir = "#{@main_config_dir}/misc/fonts"

    Dir.chdir doom_fonts_dir

    available_fonts = Dir.glob '*zip'

    available_fonts.map do |font|
      puts "Installing all fonts in: #{font}"

      fonts = `unzip -l #{font}`.split /\n/
      fonts = fonts.select { |i| i.match /^\s*[0-9]/ }
      fonts = fonts.map { |f| _f = f.split /\s+/; %{"#{_f[4..].join ' '}"} }
      fonts = fonts.select { |f| f.match /(ttf|otf)"$/ }
      `unzip -o #{font}`
      fonts.each { |f| `mv #{f} ~/.local/share/fonts/` }
      `fc-cache -fv`
    end

    puts 'Please restart your shell to load the fonts.'
  end

  def bootstrap
    `mkdir -p '#{@package_dest}' &>/dev/null`

    # setup packer
    `git clone --depth 1 https://github.com/wbthomason/packer.nvim #{@package_dest}/packer.nvim`

    # Reset packer to required commit
    reset_repo('wbthomason/packer.nvim', '7182f0ddbca2dd6f6723633a84d47f4d26518191')

    @packages.keys.each do |repo|
      commit = @packages[repo]
      clone_repo(repo)
      reset_repo(repo, commit)
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
