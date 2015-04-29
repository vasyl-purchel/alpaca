require 'mkmf'
require 'alpacabuildtool/log/log'
require 'English'

module AlpacaBuildTool
  ##
  # Tool provides basic functionality for console tools
  class Tool
    include Log

    ##
    # Creates an instance
    # It check if configuration contains 'exe' which is executable
    # If no then tries to find executable in PATH environment variable
    # If not found then get exe from block passed
    #
    # +configuration+:: hash with tool configuration
    # accepts &block with tool extended initialization if exe not found
    #
    #    Tool.new config do
    #      exe_pattern = File.join(DOWNLOAD_DIR, '**', config['exe'])
    #      install(config['id'], DOWNLOAD_DIR, true)
    #      Dir.glob(exe_pattern).first # return executable
    #    end
    def initialize(configuration)
      @configuration = configuration.dup
      @exe = @configuration['exe'] || ''
      @exe = find_executable @exe unless File.executable? @exe
      @exe = yield unless @exe || !block_given?
      @exe = encapsulate(@exe) if @exe.to_s.include? ' '
    end

    ##
    # Execute tool in console with arguments
    #
    # +args+:: tool arguments
    #
    #    tool.call(['file.cs', {c: true, type: 'test'}])
    #    # >> tool.exe file.cs /c /type:test
    def call(args)
      cmd = ([@exe] + format_arguments(args)).join ' '
      log.info ">> #{cmd}\n"
      execute cmd
    end

    private

    def format_arguments(arguments)
      arguments.map do |argument|
        case argument
        when String then encapsulate argument
        when Hash then flatten argument
        else argument.to_s
        end
      end
    end

    def encapsulate(object)
      case object.to_s
      when /^".* .*"$/ then object.to_s
      when /^.* .*$/ then "\"#{object}\""
      else object.to_s
      end
    end

    def flatten(argument)
      argument.map do |key, value|
        switch = value.nil? || value == true || value == false
        format_option key, value, switch
      end
    end

    def format_option(name, value, switch)
      switch ? "/#{name}" : "/#{name}:#{encapsulate(value)}"
    end

    def execute(cmd)
      result = system cmd
      fail "unknown command \"#{cmd}\"" if result.nil?
      fail "call #{cmd}\nfailed: #{$CHILD_STATUS}" if result == false
      result
    end
  end
end
