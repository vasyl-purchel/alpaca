require 'alpaca/tools/console_application'
require 'alpaca/tools/msbuild_formatter'

module Alpaca
  # The *MSBuild* class provides access to msbuild.exe command line tool
  class MSBuild
    include ConsoleApplication
    include MSBuildFormatter
    EXE = 'MSBuild.exe'

    # Creates instance of class for specified .Net Framework version
    #
    # +net_version+:: .Net Framework version (net451 by default)
    # - works with :net4, :net40, :net45, :net451
    # - fail for :net2, :net20, :net30, :net35
    def initialize(configuration, net_version = :net451)
      @configuration = configuration
      super("\"#{get_executable net_version}\"")
    end

    def build(solution, debug)
      config = @configuration.dup
      config['Property'] ||= {}
      config['Property']['Configuration'] = debug ? 'Debug' : 'Release'
      execute(config, [solution])
    end

    private

    def get_executable(net_version)
      case net_version
      when :net2, :net20, :net30, :net35
        fail 'sorry, not working with old versions'
      when :net4, :net40 then get_old_version('v4.0.30319')
      when :net45, :net451 then get_from_new_place('12.0')
      else fail "Don't know version #{net_version}"
      end
    end

    def get_from_new_place(version_path_part)
      path = File.join(program_files_dir.dup, 'MSBuild')
      exe = File.join(path, version_path_part, 'Bin', EXE)
      validate(exe)
      File.expand_path(exe)
    end

    def get_old_version(version_path_part)
      path = File.join(win_dir.dup, 'Microsoft.NET', 'Framework')
      exe = File.join(path, version_path_part, EXE)
      validate(exe)
      File.expand_path(exe)
    end

    def validate(exe)
      fail "Executable file '#{exe}' does not exist" unless File.exist?(exe)
    end

    def win_dir
      @win_dir ||= ENV['windir'] || ENV['WINDIR'] || ENV['C:/Windows']
    end

    def program_files_dir
      @program_files_dir ||= (
        if ENV.key?('ProgramFiles(x86)') &&
          File.exist?(ENV['ProgramFiles(x86)']) &&
          File.directory?(ENV['ProgramFiles(x86)'])
          ENV['ProgramFiles(x86)']
        else
          'C:\Program Files'
        end
      )
    end
  end
end
