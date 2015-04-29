require 'logger'
require 'alpacabuildtool/log/rainbowify_formatter'

module AlpacaBuildTool
  ##
  # RainbowifyLogger class is extending ruby logger
  # with _header_ and _puts_ methods and add colors to logs
  class RainbowifyLogger < Logger
    ##
    # Custom severities that current logger support
    SEVERITIES = %w(DEBUG INFO WARN ERROR FATAL PUTS HEADER)

    ##
    # Creates instance of logger with STDOUT as IO object
    # for logger and adds RainbowifyFormatter as a formatter
    #
    # Creates ruby logger with STDOUT object and rainbowify formatter
    def initialize
      super(STDOUT)
      @formatter = RainbowifyFormatter.new
    end

    ##
    # Override logger.format_severity in order to use our own severities
    def format_severity(severity)
      SEVERITIES[severity] || 'ANY'
    end

    ##
    # Log nice ASCII art styled header
    #
    # +progname+:: program name
    # accepts &block
    def puts(progname = nil, &block)
      add(5, nil, progname, &block)
    end

    ##
    # Log nice ASCII art styled header
    #
    # +progname+:: program name
    # accepts &block
    def header(progname = nil, &block)
      add(6, nil, progname, &block)
    end
  end
end
