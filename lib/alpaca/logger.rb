require 'date'
require 'rainbow'
require 'rainbow/ext/string' unless String.method_defined?(:color)
require 'alpaca/factories/config_factory'
require 'alpaca/entities/font'

module Alpaca
  # The *Log* module provides methods to:
  # - log info, warns, errors, headers and just log entries
  # It uses Singleton pattern and takes configuration
  # from global config file
  module Log
    # Internal class for Singelton pattern
    class Logger
      DATETIME_LOG = '%FT%T.%L' unless const_defined?(:DATETIME_LOG)

      def self.instance
        @__instance__ ||= new
      end

      # Creates instance of Logger class and load 'Logger' configuration
      def initialize
        @config = ConfigFactory['Logger']
      end

      # Logs message with specific level of logging(:info, :warn...)
      def log(level, msg)
        level = @config[level].config
        m = level['prefix'] + msg.to_s
        m = (DateTime.now.strftime(DATETIME_LOG).to_s + m) if level['stamp']
        puts rainbowfy(artify(m, level), level)
      end

      private

      def rainbowfy(msg, level)
        msg = msg.color(level['color']) if level['color']
        msg = msg.background(level['background']) if level['background']
        msg = msg.bright if level['bright']
        msg
      end

      def artify(msg, level)
        return msg unless level['font'] && level['artify']
        font = Font.new(level['font'])
        result = artify_message(msg, font)
        result.join("\n").gsub(/\0/, '').gsub(font.hard_blank, ' ')
      end

      def artify_message(msg, font)
        result = []
        msg.each_char do |c|
          o = c.ord
          o = '0' unless font.char?(o)
          font.height.times do |j|
            line = font[o][j]
            result[j] = (result[j] ||= '') + line
          end
        end
        result
      end
    end

    # Logs message with :info format
    #
    # +msg+:: message to log
    def self.info(msg)
      Logger.instance.log(:info, msg)
    end

    # Logs message with :warn format
    #
    # +msg+:: message to log
    def self.warn(msg)
      Logger.instance.log(:warn, msg)
    end

    # Logs message with :error format
    #
    # +msg+:: message to log
    def self.error(msg)
      Logger.instance.log(:error, msg)
    end

    # Logs artified message with :header format
    #
    # +msg+:: header to log(use short headers so they fit screen good)
    def self.header(msg)
      Logger.instance.log(:header, msg)
    end

    # Logs message with :log format
    #
    # +msg+:: message to log
    def self.log(msg)
      Logger.instance.log(:log, msg)
    end
  end
end
