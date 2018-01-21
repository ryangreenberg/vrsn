require 'optparse'

module Vrsn
  DDVERSION = '--version'
  SDVERSION = '-version'

  def self.cmd(name, flag, extract)
    { :name => name, :flag => flag, :extract => extract }
  end

  def self.extract(config, output)
    m = output.match(config[:extract])
    m ? m[1] : m
  end

  def self.by_name(cmds)
    Hash[cmds.map {|c| [ c[:name], c ] }]
  end

  COMMANDS = [
    cmd('git', DDVERSION, /^git version ([.0-9]+)\b/),
    cmd('java', SDVERSION, /java version "(.+?)"/),
    cmd('thrift', SDVERSION, /Thrift version (.+?)$/i),
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

      output_format = cmds.length == 1 ? "%v" : "%c\t%v"

      if options[:all]
        cmds = cmds.flat_map { |cmd| `which -a #{cmd}`.split("\n").map(&:strip) }
      end

      cmds.each.with_index do |cmd, idx|
        cmd_name = File.basename(cmd)
        config = @commands_by_name[cmd_name]
        abort "Unsupported command '#{cmd_name}'" unless config

        version_cmd = "#{cmd} #{config[:flag]} 2>&1"
        if options[:raw]
          puts cmd if cmds.length > 1
          system(version_cmd)
          puts if cmds.length > 1 && cmds.length - 1 != idx

          next
        end

        output = `#{version_cmd}`
        m = Vrsn.extract(config, output)

        abort "Unable to parse output of #{version_cmd}:\n#{output}" unless m
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
