#!/usr/bin/env ruby

require_relative('../lib/vrsn')
require 'yaml'

example_dir = File.expand_path('../examples', __FILE__)
examples = Dir.glob(File.join(example_dir, '*.yml'))

start = Time.now

counts = {
  :pass => 0,
  :fail => 0,
}

failures = []

examples.each do |exs|
  tests = YAML.load_file(exs)
  test_name = File.basename(exs)

  cmd = File.basename(exs, '.*')
  config = Vrsn::COMMANDS_BY_NAME[cmd]

  tests.each.with_index do |ex, idx|
    stdout, stderr = ex['stdout'], ex['stderr']
    expected_version = ex['version']
    example_name = "#{test_name}[#{idx}]"

    unless config
      puts "fail #{example_name}. No config for #{cmd}"
      counts[:fail] += 1
      next
    end

    actual_version = Vrsn.extract(config, stdout, stderr)

    if actual_version == expected_version
      puts "pass #{example_name} #{expected_version}"
      counts[:pass] += 1
    else
      puts "fail #{example_name} #{expected_version}"
      failures << {
        :example_name => example_name,
        :expected_version => expected_version,
        :actual_version => actual_version,
        :stdout => stdout,
        :stderr => stderr,
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
    puts "  >>> expected #{f[:expected_version]}, got #{f[:actual_version].inspect}"
    puts '  >>> stdout'
    puts (f[:stdout].empty? ? '  >>> (empty)' : f[:stdout].gsub(/^/, '  >>> ') )
    puts '  >>> '
    puts '  >>> stderr'
    puts (f[:stderr].empty? ? '  >>> (empty)' : f[:stderr].gsub(/^/, '  >>> ') )
  end
end

duration = Time.now - start

puts ""
puts "#{examples.size} files, #{total} tests, #{counts[:pass]} pass, #{counts[:fail]} failed in #{duration} secs"

exit (counts[:fail] != 0 ? 1 : 0)
