module Alpaca
  # some description for solution
  class Solution
    attr_accessor :file, :build_tool

    def initialize(file, netversion = :net45)
      @file = file
      @build_tool = MSBuild.new netversion
    end

    def to_s
      @file.to_s
    end

    def hash
      file.hash ^
        configuration.hash
    end

    def compile(configuration = :Release)
      @build_tool.run(@file) do |sln|
        sln.verbosity = 'minimal'
        sln.properties = { 'Configuration' => configuration }
        sln.targets = %w(Clean Rebuild)
      end
    end
  end

  # this also must be documented
  class MSBuild
    attr_accessor :verbosity, :targets, :properties

    def win_dir
      @win_dir ||= ENV['windir'] || ENV['WINDIR'] || ENV['C:/Windows']
    end

    def exe
      'MSBuild.exe'
    end

    def old_net(version)
      File.join(win_dir.dup, 'Microsoft.NET', 'Framework', version, exe)
    end

    def new_net(version)
      if File.exist?('C:\Program Files (x86)\MSBuild')
        File.join('C:\Program Files (x86)\MSBuild', version, 'Bin', exe)
      elsif File.exist?('C:\Program Files\MSBuild')
        File.join('C:\Program Files\MSBuild', version, 'Bin', exe)
      else
        fail "Don't have MSBuild for version #{version}"
      end
    end

    def get_old_net_version(netversion)
      case netversion
      when :net2, :net20 then 'v2.0.50727'
      when :net30 then 'v3.0'
      when :net35 then 'v3.5'
      when :net4, :net40 then 'v4.0.30319'
      else
        fail "Don't know version #{version}"
      end
    end

    def initialize(netversion = :net45)
      if netversion == :net45
        @exe = new_net('12.0')
      else
        @exe = old_net(get_old_net_version(netversion))
      end
      @exe = File.expand_path(@exe)
    end

    def to_s
      @exe.to_s
    end

    def run(file, &block)
      instance_eval(&block) if block_given?
      args = %W(#{file})
      args += %W(/verbosity:#{@verbosity}) if @verbosity
      args += %W(/target:#{@targets.join(';')}) if @targets
      props_args = @properties.map { |k, v| "#{k}=#{v}" }.join(';')
      args += %W(/property:#{props_args}) if @properties
      puts "#{@exe} #{args}"
      system @exe, *args
    end
  end
end
