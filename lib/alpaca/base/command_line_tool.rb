require 'alpaca/base/configurable'
require 'alpaca/base/logger'

module Alpaca
  # The *Cmd* module provides methods to make it easy to use
  # any command line tool like git, nuget and so on
  module CommandLineTool
    include Configurable
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
    def run(command, argument, &block)
      instance_eval(&block) if block_given?
      args = configured_attributes_as_arguments(@prefix, @separator,
                                                @formatter)
      call = [@exe, command]
      call += (@arg_to_left ? [argument] + args : args + [argument])
      call = call.join(' ')
      info(">> #{call}")
      `#{call}`
      clear_configuration
    end
  end
end
