require 'date'
require 'ostruct'
require 'rainbow'
require 'rainbow/ext/string' unless String.method_defined?(:color)
require 'alpaca/entities/font'
require 'alpaca/configuration'

module Alpaca
  # The *Log* module provides methods to log for levels:
  # - :info
  # - :warns
  # - :errors
  # - :headers
  # - :log
  module Log
    DATETIME_LOG = '%FT%T.%L' unless const_defined?(:DATETIME_LOG)

    # Logs message with :info format
    #
    # +msg+:: message to log
    def info(msg)
      log(msg, :info)
    end

    # Logs message with :warn format
    #
    # +msg+:: message to log
    def warn(msg)
      log(msg, :warn)
    end

    # Logs message with :error format
    #
    # +msg+:: message to log
    def error(msg)
      log(msg, :error)
    end

    # Logs artified message with :header format
    #
    # +msg+:: header to log(use short headers so they fit screen good)
    def header(msg)
      log(msg, :header)
    end

    # Logs message
    #
    # +msg+:: message to log
    # +[level]+:: specify log level, (:log by default)
    def log(msg, level = :log)
      config = log_configuration(level)
      m = config['prefix'] + msg.to_s
      m = (DateTime.now.strftime(DATETIME_LOG).to_s + m) if config['stamp']
      puts rainbowfy(artify(m, config), config)
    end

    private

    def log_configuration(level)
      default =  { 'prefix' => " #{level}\t> ", 'stamp' => true }
      solution_stub = OpenStruct.new
      solution_stub.file = 'log'
      solution_stub.dir = 'log'
      @log_config ||= Configuration.new solution_stub
      @log_config['Logger'][level] || default
    end

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
end
