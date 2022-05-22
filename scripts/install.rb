#!/usr/bin/ruby2.7

require 'yaml'

luarocks_dst = File.join(ENV['HOME'], '.local', 'share', 'nvim', 'luarocks')
plugins_dst = File.join(ENV['HOME'], '.local', 'share', 'nvim', 'site', 'pack', 'packer', 'start')

not Dir.exist?(luarocks_dst) && `mkdir -p #{luarocks_dst}`
not Dir.exist?(plugins_dst) && `mkdir -p #{luarocks_dst}`

YAML.load_file('luarocks.yaml').each {|rock| 
  `luarocks --tree #{luarocks_dst} install #{rock}`
}

YAML.load_file('plugins.yaml').each { |plug, args| 
  commit, cmd_args = args
  url = 'https://github.com/' + plug.sub(%r(^/), '')
  name = plug.match(%r{(?<=/)([^$]+)})
  dst = File.join(plugins_dst, name.to_s)
  `git clone #{cmd_args} #{url} #{dst}`

  cwd = Dir.pwd()
  if commit then
    Dir.chdir(dst)
    `git --reset hard #{commit}`
    Dir.chdir(cwd)
  end
}
