require 'alpacabuildtool/log/rainbowify_logger'

module AlpacaBuildTool
  ##
  # Log adds logger to any class that include it
  module Log
    attr_writer :log

    ##
    # Method gives access to logger with lazy initialization
    def log
      @log ||= RainbowifyLogger.new
    end
  end
end
