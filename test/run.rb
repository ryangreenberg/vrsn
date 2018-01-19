#!/usr/bin/env ruby

load File.expand_path('../../bin/vrsn', __FILE__)
require 'yaml'

example_dir = File.expand_path('../examples', __FILE__)
examples = Dir.glob(File.join(example_dir, '*.yml'))

counts = {
  :pass => 0,
  :fail => 0,
}

failures = []

examples.each do |exs|
  tests = YAML.load_file(exs)
  test_name = File.basename(exs)

  cmd = File.basename(exs, '.*')
  config = COMMANDS_BY_NAME[cmd]

  tests.each.with_index do |ex, idx|
    input = ex['input']
    expected_output = ex['output']
    example_name = "#{test_name}[#{idx}]"

    unless config
      puts "fail #{example_name}. No config for #{cmd}"
      counts[:fail] += 1
      next
    end

    actual_output = extract(config, input)

    if actual_output == expected_output
      puts "pass #{example_name} #{expected_output}"
      counts[:pass] += 1
    else
      puts "fail #{example_name} #{expected_output}"
      failures << {
        :example_name => example_name,
        :expected_output => expected_output,
        :actual_output => actual_output,
        :input => input
      }
      counts[:fail] += 1
    end
  end
end

total = counts[:pass] + counts[:fail]

unless failures.empty?
  puts ""
  puts "FAILURES"
  failures.each do |f|
    puts f[:example_name]
    puts "  >>> expected #{f[:expected_output]}, got #{f[:actual_output]}"
    puts f[:input].gsub(/^/, '  >>> ')
  end
end

puts ""
puts "#{examples.size} files, #{total} tests, #{counts[:pass]} pass, #{counts[:fail]} failed"

exit (counts[:fail] != 0 ? 1 : 0)
