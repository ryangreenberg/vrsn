#!/usr/bin/env ruby

require_relative('../lib/vrsn')
require 'set'
require 'yaml'

example_dir = File.expand_path('../examples', __FILE__)
examples = Dir.glob(File.join(example_dir, '*.yml'))

start = Time.now

counts = {
  :pass => 0,
  :fail => 0,
}

failures = []

def print_failure(failure)
  case failure[:type]
  when :missing_examples
    puts failure[:cmd_name]
    puts "  >>> missing test cases for #{failure[:cmd_name]} in #{failure[:expected_path]}"
  when :failed_example
    puts failure[:example_name]
    puts "  >>> expected #{failure[:expected_version]}, got #{failure[:actual_version].inspect}"
    puts '  >>> stdout'
    puts (failure[:stdout].empty? ? '  >>> (empty)' : failure[:stdout].gsub(/^/, '  >>> ') )
    puts '  >>> '
    puts '  >>> stderr'
    puts (failure[:stderr].empty? ? '  >>> (empty)' : failure[:stderr].gsub(/^/, '  >>> ') )
  else
    raise RuntimeError, "Cannot output unknown failure type for #{failure.inspect}"
  end
end

# Check that all implemented commands have a test example
ex_set = Set.new(examples.map {|ex| File.basename(ex, '.yml') })
Vrsn::COMMANDS_BY_NAME.each do |cmd_name, _|
  expected_path = "#{example_dir}/#{cmd_name}.yml"
  if ex_set.include?(cmd_name)
    counts[:pass] += 1
    puts "pass: #{cmd_name} examples present in #{expected_path}"
  else
    counts[:fail] += 1
    failures << {
      :type => :missing_examples,
      :cmd_name => cmd_name,
      :expected_path => expected_path,
    }
    puts "fail: #{cmd_name} examples missing in #{expected_path}"
  end
end
puts ""

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
        :type => :failed_example,
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
  failures.each { |f| print_failure(f) }
end

duration = Time.now - start

puts ""
puts "#{examples.size} files, #{total} tests, #{counts[:pass]} pass, #{counts[:fail]} failed in #{duration} secs"

exit (counts[:fail] != 0 ? 1 : 0)
