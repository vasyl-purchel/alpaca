require_relative 'logger'

module Alpaca
  # The *Executable* module provides method to:
  # - execute command with arguments and log it before execution
  module Executable
    include Logger

    # Logs and executes command with arguments
    #
    # +exe+:: command line tool to be executed
    # +args+:: arguments for this tool
    def execute(exe, args)
      call = ([exe] + args).join(' ')
      info(">> #{call}")
      `#{call}`
    end
  end
end
