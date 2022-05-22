#!/usr/bin/ruby2.7

case ARGV[0]
when /^-?-?(list|show|help|h)$/
  tags = `git tag --list`
  puts tags
when /set/
  if ARGV[1] then
    tags = (`git tag --list`).chomp.split(/\n/)
    required = tags.filter {|t| t =~ Regexp.compile(ARGV[1])}

    if required.length > 0 then
      `git checkout #{required.pop}`
    else
      puts 'No matching version found for query: ' + ARGV[1]
    end
  end
else
    puts 'No commands passed. Pass "show" to show the list of versions and "set" to set a particular version'
end
