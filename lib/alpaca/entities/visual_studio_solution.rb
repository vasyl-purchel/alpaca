require 'alpaca/log'
require 'alpaca/configuration'
require 'alpaca/entities/visual_studio_project'
require 'alpaca/tools/nuget'
require 'alpaca/tools/msbuild'

module Alpaca
  # Class *VisualStudioSolution* provides solution
  # representation and methods to manipulate it
  class VisualStudioSolution
    BUILD_VERSION = '%M.%m.%p'

    include Log

    attr_accessor :file, :dir, :net_version
    attr_accessor :format_version
    attr_accessor :visual_studio_version, :minimum_visual_studio_version
    attr_accessor :projects

    # Creates instance of class
    #
    # +file+:: solution file
    #
    #   s = Alpaca::VisualStudioSolution.new 'some.sln'
    #     # => #<**:VisualStudioSolution:** @file="d:/some.sln" **>
    def initialize(file)
      @file = File.expand_path(file)
      fail "Can't find file #{@file}" unless File.exist?(@file)
      @dir = File.dirname(@file)
      IO.readlines(@file).each { |line| initialize_data line }
      @configuration = Configuration.new(self)
      @semver = Versioning.find(@dir)
    end

    # Overrides *to_s* method to provide nice convertion to string
    # Returns multiple lines
    def to_s
      s = "------------\nFile: #{@file}"
      s += "\nFormat version: #{@format_version}"
      s += "\nVisual studio version: #{@visual_studio_version}"
      s += "\nMinimum visual studio version: #{@minimum_visual_studio_version}"
      s += "\nProjects:" unless @projects.empty?
      @projects.each { |p| s += "\n\t#{p}" }
      s += "\n------------"
      s
    end

    def compile(debug)
      return if stub?
      info "compiling in #{debug ? 'debug' : 'release'} mode..."
      build_version = @semver.to_s BUILD_VERSION
      @projects.each { |project| project.update_version(build_version) }
      Nuget.new(@configuration['Nuget']).restore(@file) if nuget?
      MSBuild.new(@configuration['MSBuild']).build(@file, debug)
    end

    def test(debug, coverage, category)
      # nunit_config = CONF['NUnit', s.file]
      # tp = File.dirname(s.file).to_s
      # tp += '/Unit.Tests/Wonga.CashIn.Inbound.Unit.Tests.csproj'
      # nunit_args = [tp]
      # n = Alpaca::NUnit.new nunit_config.exe
      mode = debug ? 'Debug' : 'Release'
      if coverage
        info "testing in #{mode} mode with coverage for category #{category}.."
        # opencover_config = CONF['OpenCover', s.file]
        # o = Alpaca::OpenCover.new opencover_config.exe, n
        # o.execute(opencover_config.options, []) do |t|
        # t.execute(nunit_config.options, nunit_args)
        # end
      else
        info "testing in #{mode} mode for category #{category}.."
        # n.execute(nunit_config.options, nunit_args)
      end
    end

    def report(category)
      info "generating report for category #{category}.."
    end

    def pack
      info 'creating packages :O'
    end

    def release(push)
      info "releasing package#{push ? ' and pushing it' : ''}"
    end

    def push(force)
      info "#{force ? 'force ' : ''}pushing package"
    end

    private

    def initialize_data(line)
      case line
      when /^Project/
        then (@projects ||= []) << VisualStudioProject.new(line, @dir)
      when /.*Format Version [\d\.]+/
        then @format_version = parse_version(line)
      when /^VisualStudioVersion/
        then @visual_studio_version = parse_version(line)
      when /^MinimumVisualStudioVersion/
        then @minimum_visual_studio_version = parse_version(line)
      end
    end

    def parse_version(s)
      s.gsub(/[\d\.]+/).first
    end

    def nuget?
      !Dir.glob(@dir + '/**/packages.config').empty?
    end

    def stub?
      solution_name = File.basename(@file, '.*')
      (@configuration['no_build'] || []).each do |tag|
        return true if solution_name.include?(tag)
      end
      false
    end
  end
end
