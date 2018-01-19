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

  COMMANDS = [
    cmd('java', SDVERSION, /java version "(.+?)"/),
    cmd('thrift', SDVERSION, /Thrift version (.+?)$/i),
  ]

  COMMANDS_BY_NAME = Hash[COMMANDS.map {|c| [ c[:name], c ] }]

  class CLI
    USAGE = 'vrsn <command>'

    def initialize(args)
      @args = args
    end

    def main
      cmd = @args.last
      abort USAGE unless cmd

      config = COMMANDS_BY_NAME[cmd]
      abort "Unsupported command '#{cmd}'" unless config

      version_cmd = "#{cmd} #{config[:flag]} 2>&1"
      output = `#{version_cmd}`
      m = Vrsn.extract(config, output)

      abort "Unable to parse output of #{version_cmd}:\n#{output}" unless m
      puts m
    end
  end
end
