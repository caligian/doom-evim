#!/usr/bin/ruby2.7

main_config_dir = File.join(ENV['HOME'], '.config', 'nvim')
doom_fonts_dir = "#{main_config_dir}/misc/fonts"
Dir.chdir(doom_fonts_dir)
available_fonts = Dir.glob('*zip')

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
