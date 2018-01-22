require 'open3'
require 'optparse'

module Vrsn
  DDVERSION = '--version'
  SDVERSION = '-version'

  def self.cmd(name, flag, extract)
    { :name => name, :flag => flag, :extract => extract }
  end

  def self.match_stdout(pattern)
    lambda {|stdout, _| m = stdout.match(pattern); m ? m[1] : m }
  end

  def self.match_stderr(pattern)
    lambda {|_, stderr| m = stderr.match(pattern); m ? m[1] : m }
  end

  def self.extract(config, stdout, stderr)
    config[:extract].call(stdout, stderr)
  end

  def self.by_name(cmds)
    Hash[cmds.map {|c| [ c[:name], c ] }]
  end

  COMMANDS = [
    cmd('brew', DDVERSION, match_stdout(/^Homebrew (.+?)$/)),
    cmd('git', DDVERSION, match_stdout(/^git version ([.0-9]+)\b/)),
    cmd('java', SDVERSION, match_stderr(/java version "(.+?)[_"]/)),
    cmd('node', DDVERSION, match_stdout(/^v(.+?)$/)),
    cmd('npm', DDVERSION, match_stdout(/^(.+?)$/)),
    cmd('php', DDVERSION, match_stdout(/^PHP (.+?) /)),
    cmd('python', DDVERSION, match_stderr(/^Python (.+?)$/)),
    cmd('ruby', DDVERSION, match_stdout(/^ruby (.+?)p/)),
    cmd('scala', SDVERSION, match_stderr(/version (.+?) --/)),
    cmd('thrift', SDVERSION, match_stdout(/Thrift version (.+?)$/i)),
  ]

  COMMANDS_BY_NAME = by_name(COMMANDS)

  class CLI
    USAGE = 'vrsn <command>'

    def initialize(args, commands_by_name = COMMANDS_BY_NAME)
      @args = args
      @commands_by_name = commands_by_name
    end

    def main
      options = parsed_args
      cmds = options[:remaining]
      abort USAGE if cmds.empty?

      if options[:all]
        cmds = cmds.flat_map { |cmd| `which -a #{cmd}`.split("\n").map(&:strip) }
      end

      output_format = cmds.length == 1 ? "%v" : "%c\t%v"

      cmds.each.with_index do |cmd, idx|
        cmd_name = File.basename(cmd)
        config = @commands_by_name[cmd_name]
        abort "Unsupported command '#{cmd_name}'" unless config

        version_cmd = "#{cmd} #{config[:flag]}"
        if options[:raw]
          puts cmd if cmds.length > 1
          # Ensure that all version output consistently goes to stdout
          system("#{version_cmd} 2>&1")
          puts if cmds.length > 1 && cmds.length - 1 != idx

          next
        end

        # output = `#{version_cmd}`
        stdout, stderr, status = Open3.capture3(cmd, config[:flag])
        m = Vrsn.extract(config, stdout, stderr)

        abort "Unable to parse output of #{version_cmd}:\n#{stdout}\n\n#{stderr}" unless m
        puts format(output_format, { :version => m, :command => cmd })
      end
    end

    def format(str, options)
      str.
        gsub(/%v\b/, options[:version]).
        gsub(/%c\b/, options[:command])
    end

    def parsed_args
      options = {
        :all => false,
        :raw => false,
      }

      parser = OptionParser.new do |opts|
        opts.on('-a', '--all', 'Show the version of all matching commands in the current $PATH.') do
          options[:all] = true
        end

        opts.on('-r', '--raw', 'Run the command and show its version output verbatim.') do
          options[:raw] = true
        end
      end

      options[:remaining] = parser.parse(@args)

      options
    end
  end
end
