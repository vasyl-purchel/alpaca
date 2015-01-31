require 'rbconfig'

module Alpaca
  # MSBuild can be used to build Visual Studio solutions
  module MSBuild
    EXE = 'MSBuild.exe'

    def self.executable(net_version = :net451)
      case net_version
      when :net2, :net20, :net30, :net35
        fail 'sorry, not working with old versions'
      when :net4, :net40 then get_old_version('v4.0.30319')
      when :net45, :net451 then get_from_new_place('12.0')
      else fail "Don't know version #{net_version}"
      end
    end

    def self.backdoor(&block)
      instance_eval(&block) if block_given?
    end

    def self.get_from_new_place(version_path_part)
      path = File.join(program_files_dir.dup, 'MSBuild')
      exe = File.join(path, version_path_part, 'Bin', EXE)
      validate(exe)
      File.expand_path(exe)
    end

    def self.get_old_version(version_path_part)
      path = File.join(win_dir.dup, 'Microsoft.NET', 'Framework')
      exe = File.join(path, version_path_part, EXE)
      validate(exe)
      File.expand_path(exe)
    end

    def self.validate(exe)
      fail "Executable file '#{exe}' does not exist" unless File.exist?(exe)
    end

    def self.win_dir
      @win_dir ||= ENV['windir'] || ENV['WINDIR'] || ENV['C:/Windows']
    end

    def self.program_files_dir
      @program_files_dir ||= (
        if ENV.key?('ProgramFiles(x86)') &&
          File.exist?(ENV['ProgramFiles(x86)']) &&
          File.directory?(ENV['ProgramFiles(x86)'])
          'C:\Program Files (x86)'
        else
          'C:\Program Files'
        end
      )
    end

    private_class_method :get_from_new_place
    private_class_method :get_old_version
    private_class_method :validate
    private_class_method :win_dir
    private_class_method :program_files_dir
  end
end
