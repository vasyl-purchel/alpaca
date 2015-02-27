require 'date'
require 'rainbow'
require 'rainbow/ext/string' unless String.method_defined?(:color)
require 'alpaca/ext/string' unless String.method_defined?(:artify)

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

    # Logs nice green header
    #
    # +msg+:: header to log(use short headers so they fit screen good)
    def header(msg)
      puts msg.to_s.artify('doom').color(:green).bright
    end
  end

  # The *Log* class provides log methods outside of
  # classes scope
  class Log
    include Logger

    def self.info(msg)
      (@instance ||= Log.new).info(msg)
    end

    def self.warn(msg)
      (@instance ||= Log.new).warn(msg)
    end

    def self.error(msg)
      (@instance ||= Log.new).error(msg)
    end

    def self.header(msg)
      (@instance ||= Log.new).header(msg)
    end
  end
end
