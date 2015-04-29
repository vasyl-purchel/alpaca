require 'date'
require 'logger'
require 'rainbow'
require 'rainbow/ext/string' unless String.method_defined?(:color)
require 'alpacabuildtool/log/font'

module AlpacaBuildTool
  ##
  # RainbowifyFormatter provides formatting for standart
  # ruby logger by adding colors(rainbow gem) and ASCII art headers
  # for HEADER (6) severity
  class RainbowifyFormatter < Logger::Formatter
    ##
    # Provides custom logging implementation
    #
    # +severity+:: severity to log(HEADER, PUTS, INFO, ERROR...)
    # +datetime+:: date time stamp
    # +progname+:: not used here
    # +message+:: message to log
    def call(severity, datetime, _progname, message)
      case severity
      when 'HEADER' then header(message)
      when 'PUTS' then puts(message)
      else usual(message, severity, datetime)
      end
    end

    private

    def header(message)
      font = Font.new('doom')
      result = artify_message("\x00#{message}", font)
      result.join("\n").gsub(/\0/, '').gsub(font.hard_blank, ' ')
        .color(:green).bright + "\n"
    end

    def puts(message)
      message.to_s.color(:blue).bright + "\n"
    end

    def usual(message, severity, datetime)
      date_format = datetime.strftime('%FT%T.%L')
      "[#{date_format}] #{severity}: #{message}".color(color(severity)) + "\n"
    end

    def color(severity)
      case severity
      when 'DEBUG' then :cyan
      when 'INFO' then :green
      when 'WARN' then :yellow
      when 'ERROR' then :red
      when 'FATAL' then :magenta
      else :white
      end
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
