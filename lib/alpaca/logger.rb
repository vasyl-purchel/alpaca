require 'date'
require 'rainbow'
require 'rainbow/ext/string' unless String.method_defined?(:color)

module Alpaca
  # The *Logger* module provides methods to:
  # - log info, warns and errors
  module Logger
    DATETIME_LOG = '%FT%T.%L' unless const_defined?(:DATETIME_LOG)

    # Logs message with timestamp and INFO format
    #
    # +msg+:: message to log
    def info(msg)
      dt = DateTime.now.strftime(DATETIME_LOG)
      puts "[#{dt}] INFO: #{msg}".color(:black).background(:green)
    end

    # Logs message with timestamp and WARN format
    #
    # +msg+:: message to log
    def warn(msg)
      dt = DateTime.now.strftime(DATETIME_LOG)
      puts "[#{dt}] WARN: #{msg}".color(:black).background(:yellow)
    end

    # Logs message with timestamp and ERROR format
    #
    # +msg+:: message to log
    def error(msg)
      dt = DateTime.now.strftime(DATETIME_LOG)
      puts "[#{dt}] ERROR: #{msg}".color(:black).background(:red)
    end
  end
end
