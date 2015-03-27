require 'alpaca/log'

module Alpaca
  # The *ConsoleTool* module provides simple access to
  # console applications by providing standartized interface
  module ConsoleTool
    include Log

    def initialize(exe)
      @exe = exe
    end

    def execute(args)
      run(([@exe] + args).join(' '))
    end

    def run(call)
      info(">> #{call}")
      result = system(call)
      fail "unknown command \"#{call}\"" if result.nil?
      fail "failed with #{$CHILDSTATUS.exitstatus}" if result == false
      result
    end
  end
end
