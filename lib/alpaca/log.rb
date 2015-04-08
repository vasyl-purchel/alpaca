require 'date'
require 'ostruct'
require 'rainbow'
require 'rainbow/ext/string' unless String.method_defined?(:color)
require 'alpaca/entities/font'
require 'alpaca/configuration'

require 'logger'

module Alpaca
  # The *RainbowifyLogger* class is extending ruby logger
  # with _header_ and _puts_ methods and add colors to logs
  class RainbowifyLogger < Logger
    SEVERITIES = %w(DEBUG INFO WARN ERROR FATAL PUTS HEADER)

    # Creates instance of logger with STDOUT as IO object
    # for logger and adds RainbowifyFormatter as a formatter
    def initialize
      super(STDOUT)
      @formatter = RainbowifyFormatter.new
    end

    # Override logger.format_severity in order to use our own severities
    def format_severity(severity)
      SEVERITIES[severity] || 'ANY'
    end

    # Log nice ASCII art styled header
    #
    # +progname+:: program name
    # accepts &block
    def header(progname = nil, &block)
      add(6, nil, progname, &block)
    end

    # Log nice ASCII art styled header
    #
    # +progname+:: program name
    # accepts &block
    def puts(progname = nil, &block)
      add(5, nil, progname, &block)
    end
  end

  # Class *RainbowifyFormatter* provides formatting for standart
  # ruby logger by adding colors(rainbow gem) and ASCII art headers
  # for HEADER (6) severity
  class RainbowifyFormatter < Logger::Formatter
    def call(severity, datetime, _progname, message)
      date_format = datetime.strftime('%FT%T.%L')
      result = "[#{date_format}] #{severity}: #{message}"
      result = "#{message}" if severity == 'PUTS'
      result = "\x00#{message}" if severity == 'HEADER'
      config = configuration(severity)
      rainbowfy(artify(result, config), config)
    end

    private

    def configuration(severity)
      case severity
      when 'DEBUG' then { color: :black, background: :green }
      when 'INFO' then { color: :green }
      when 'WARN' then { color: :yellow }
      when 'ERROR' then { color: :red }
      when 'FATAL' then { color: :red, bright: true }
      else extended_configuration severity
      end
    end

    def extended_configuration(severity)
      case severity
      when 'PUTS' then { color: :white, background: :green }
      when 'HEADER' then { color: :green, bright: true, font: 'doom' }
      else { color: :blue }
      end
    end

    def rainbowfy(msg, config)
      msg = msg.color(config[:color]) if config[:color]
      msg = msg.background(config[:background]) if config[:background]
      msg = msg.bright if config[:bright]
      msg
    end

    def artify(msg, config)
      return msg unless config[:font]
      font = Font.new(config[:font])
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

  # Module *Log* adds logger
  module Log
    attr_writer :log

    # Method gives access to logger with lazy initialization
    def log
      @log ||= RainbowifyLogger.new
    end
  end
end
