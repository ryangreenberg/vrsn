#!/usr/bin/env ruby

require 'open3'
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

# Could check that exit status is 0, but there may be some
# oddball commands that exit non-zero
cmd_with_flag = "#{cmd} #{flag}"
stdout, stderr, status = Open3.capture3(cmd, flag)
stdout = stdout.strip
stderr = stderr.strip

cmd_name = File.basename(cmd)

puts "Run:"
puts "  #{cmd_with_flag}"
puts
puts "Output (stdout):"
puts stdout.gsub(/^/, '  ')
puts
puts "Output (stderr):"
puts stderr.gsub(/^/, '  ')
puts

expected = ask("Expected version for this output") if expected == :ask_later
puts "Expected version:"
puts "  #{expected}"
puts

# Added example ## to file
example_file = "#{cmd_name}.yml"
example_path = File.expand_path("../examples/#{example_file}", __FILE__)

examples = if File.exist?(example_path)
  obj = YAML.load_file(example_path)
  obj.is_a?(Array) ? obj : []
else
  []
end

existing_example, idx = examples.detect {|ex| ex['stdout'] == stdout && ex['stderr'] == stderr && ex['version'] == expected }
if existing_example
  puts "Not adding to #{example_path}, found existing example:"
  p existing_example
  puts
else
  new_example = {
    'stdout' => stdout,
    'stderr' => stderr,
    'version' => expected,
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
puts %|  cmd('#{cmd}', #{impl_flag}, match_stdout(/^(.+?)$/))|
