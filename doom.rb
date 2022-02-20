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
      'wbthomason/packer.nvim' => '7182f0ddbca2dd6f6723633a84d47f4d26518191',
      'nvim-lua/plenary.nvim' => '563d9f6d083f0514548f2ac4ad1888326d0a1c66',
      'caligian/fennel.vim' => '06c8bf2895fcf93338b4c64690b2043605a4527c',
      'folke/which-key.nvim' => '28d2bd129575b5e9ebddd88506601290bb2bb221',
      'kreskij/Repeatable.vim' => 'ab536625ef25e423514105dd790cb8a8450ec88b',
      'drewtempelmeyer/palenight.vim' => '847fcf5b1de2a1f9c28fdcc369d009996c6bf633',
      'lewis6991/impatient.nvim' => 'c602af04b487643b4b3f7f9aa9b4aea38a596b94',
      'Olical/aniseed' => '7968693e841ea9d2b4809e23e8ec5c561854b6d6',
      'Olical/conjure' => '2717348d1a0687327f59880914fa260e4ad9c685',
      'svermeulen/vimpeccable' => 'bd19b2a86a3d4a0ee184412aa3edb7ed57025d56',
      'nvim-lualine/lualine.nvim' => 'dc20cbd0a99ff1345a8186ada1fb5fb2ca3e3fdf',
      'dracula/vim' => '74f63c304a0625c4ff9ce16784fce583b3a60661',
      'jnurmine/Zenburn' => 'de2fa06a93fe1494638ec7b2fdd565898be25de6',
      'gosukiwi/vim-atom-dark' => '44feadcbeb2a8b2a21e373261a6293679f79da94',
      'sainnhe/everforest' => 'cbcb08bc1e0cd0d950d7c0fa663b2f6203b7f8e7',
      'pineapplegiant/spaceduck' => '0d06e20f8390b58de3e69a1ac5c43d2ca833ce39',
      'archseer/colibri.vim' => 'ad82132e0cbbdfa194d722f15c2df8f0d04b5b71',
      'haishanh/night-owl.vim' => '783a41a27f7fe55ed91d1ec0f0351d06ae17fbc7',
    }
  end

  def set_doom_version
    # Fetch all tags first
    # And other updates
    `bash -c "git pull origin main &>/dev/null"`

    # Get tags
    tags = `git tag --list`
    tags = tags.split /\n/

    show_tags = ->() {
      tags.each_with_index { |t, idx|
        printf("%-3s %s\n", "#{idx}." , t)
      }
    }

    get_input = ->(current_input) {
      if !current_input
        show_tags.call()

        printf "Enter index %% "

        current_input = gets().strip()

        if ! current_input
          get_input.call(false)
        elsif !(current_input =~ /^[0-9]+$/)
          puts "Invalid input supplied."
          get_input.call(false)
        elsif current_input.to_i < 0 or current_input.to_i > (tags.length - 1)
          puts "Invalid index provided."
          get_input.call(false)
        else
          get_input.call(current_input)
        end
      else
        tags[current_input.to_i]
      end
    }

    version = get_input.call(false)
    `bash -c "git checkout #{version} &>/dev/null"`
    puts "Doom version has been set to #{version}"
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
elsif args =~ /set-version/
  SetupDoom.new.set_doom_version
elsif args =~ /help/
  puts <<"ENDSTRING"
  bootstrap         Installs essentials packages required by doom
  setup-lua         Install the required luarocks
  make-user-fs      Make ~/.vdoom.d/ and insert sample files in it
  install-fonts     Install several fonts to ~/.local/share/fonts
  setup-all         Do all of the above
  set-version       Display an interactive menu to set the doom version
ENDSTRING
elsif args == ''
  puts "No command passed. Pass `help` to see the commands."
else
  puts "Invalid command passed: #{args}"
end
