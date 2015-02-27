require 'alpaca/base/logger'

module Alpaca
  # The *Cmd* module provides methods to make it easy to use
  # any command line tool like git, nuget and so on
  module CommandLineTool
    include Logger

    # Initializes new instance format and executable path
    #
    # +exe+:: executable path
    # +prefix+:: prefix for command line options
    # +separator+:: command line options name and value separator
    def initialize(exe, prefix, separator, arg_to_left = true, formatter = nil)
      @exe, @prefix, @separator = exe, prefix, separator
      @arg_to_left, @formatter = arg_to_left, formatter
    end

    # Log and execute command with argument on the tool
    #
    # +command+:: tool command
    # +argument+:: command argument
    # +&block+:: accepts block with configuration for tool options
    def run(command, argument, config = nil)
      args = []
      args = configuration_to_args(config) unless config.nil?
      call = [@exe, command] + order(argument, args, @arg_to_left)
      call = call.join(' ')
      info(">> #{call}")
      system(call)
    end

    def order(a, b, a_to_left)
      a = [a] unless a.is_a?(Array)
      b = [b] unless b.is_a?(Array)
      a_to_left ? a + b : b + a
    end

    def configuration_to_args(config)
      if config.is_a?(String)
        fail Errors::ConfigNotFound unless File.exist?(file_or_config)
        config = YAML.load(File.open(file_or_config)) || {}
      end
      fail Errors::WrongConfiguration unless config.is_a?(Hash)
      config.to_a.map { |c| pair_to_arg(c[0], c[1]) }
    end

    def pair_to_arg(name, value)
      @formatter ||= BaseFormatter.new
      n, v = @formatter.format(name, value)
      arg = %W(#{@prefix} #{n})
      arg += %W(#{@separator} #{v}) unless switch?(value)
      arg.join('')
    end

    def switch?(value)
      value.nil? || value == true || value == false
    end
  end
end
