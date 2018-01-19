#!/usr/bin/env ruby

require 'yaml'

USAGE = "#{$PROGRAM_NAME} <command> <version flag> <expected output>"

YAML_SETTINGS = {
  :indentation => 4,
  :line_width => 80
}

def ask(prompt)
  print "#{prompt}: "
  STDIN.gets.strip
end

cmd = ARGV[0] || ask("Command name")
flag = ARGV[1] || ask("Version flag")
expected = ARGV[2] || :ask_later

abort USAGE unless cmd && flag
abort "Commands must be on the top-level of the user's PATH (they cannot contain '/')" if cmd.include?('/')

# Could check that exit status is 0, but there may be some
# oddball commands that exit non-zero
cmd_with_flag = "#{cmd} #{flag}"
output = `#{cmd_with_flag} 2>&1`.strip

puts "Run:"
puts "  #{cmd_with_flag}"
puts
puts "Output:"
puts output.gsub(/^/, '  ')
puts

expected = ask("Expected version for this output") if expected == :ask_later
puts "Expected version:"
puts "  #{expected}"
puts

# Added example ## to file
example_file = "#{cmd}.yml"
example_path = File.expand_path("../examples/#{example_file}", __FILE__)

examples = if File.exist?(example_path)
  YAML.load_file(example_path)
else
  []
end

existing_example, idx = examples.detect {|ex| ex['input'] == output && ex['output'] == expected }
if existing_example
  puts "Not adding to #{example_path}, found existing example:"
  p existing_example
  puts
else
  new_example = {
    'input' => output,
    'output' => expected,
  }
  examples << new_example
  File.open(example_path, 'w') {|f| f << examples.to_yaml(YAML_SETTINGS) }

  puts "Added example #{examples.size} to #{File.basename(example_path)}"
  puts
end

puts "Stub implementation:"
impl_flag = case flag
when '--version' then 'DDVERSION'
when '-version' then 'SDVERSION'
else "'#{flag}'"
end
puts %|  cmd('#{cmd}', #{impl_flag}, /^(.+?)$/)|
