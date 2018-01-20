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

      cmds.each do |cmd|
        config = @commands_by_name[cmd]
        abort "Unsupported command '#{cmd}'" unless config

        version_cmd = "#{cmd} #{config[:flag]} 2>&1"
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
      options = {}

      parser = OptionParser.new do |opts|
      end

      options[:remaining] = parser.parse(@args)

      options
    end
  end
end
