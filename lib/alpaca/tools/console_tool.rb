require 'alpaca/logger'

module Alpaca
  # The *ConsoleTool* module provides simple access to
  # console applications by providing standartized interface
  module ConsoleTool
    def initialize(exe)
      @exe = exe
    end

    def execute(args)
      run(([@exe] + args).join(' '))
    end

    def run(call)
      Log.info(">> #{call}")
      system(call)
    end
  end
end
