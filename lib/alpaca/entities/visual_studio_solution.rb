require 'alpaca/log'

module Alpaca
  # VisualStudio solution
  class VisualStudioSolution
    include Log

    attr_accessor :file, :folder, :net_version
    attr_accessor :format_version
    attr_accessor :visual_studio_version, :minimum_visual_studio_version
    attr_accessor :projects

    # Creates instance of class
    #
    # +file+:: solution file
    #
    #   s = Alpaca::Solution.new 'some.sln'
    #     # => #<**:Solution:** @file="d:/some.sln" **>
    def initialize(file)
      @file = File.expand_path(file)
      fail "Can't find file #{@file}" unless File.exist?(@file)
      @folder = File.dirname(@file)
      IO.readlines(@file).each { |line| initialize_data line }
    end

    # Overrides *to_s* method to provide nice convertion to string
    # Returns multiple lines
    def to_s
      s = "------------\nFile: #{@file}"
      s += "\nFormat version: #{@format_version}"
      s += "\nVisual studio version: #{@visual_studio_version}"
      s += "\nMinimum visual studio version: #{@minimum_visual_studio_version}"
      s += "\nProjects:" unless @projects.empty?
      @projects.each { |p| s += "\n\t{#{p[:name]};#{p[:file]}}" }
      s += "\n------------"
      s
    end

    def compile(debug)
      info "compiling in #{debug ? 'debug' : 'release'} mode..."
      # n_c, n_cmd = CONF['Nuget', s.file], 'restore'
      # Alpaca::Nuget.new(n_c.exe)
      # .execute({}, n_cmd, n_c.options(n_cmd), [s.file])
      # LOG.info 'Building solution'
      # m_c = CONF['MSBuild', s.file].with(property: { configuration: conf })
      # Alpaca::MSBuild.new.execute(m_c, s.file)
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
      when /^Project/ then (@projects ||= []) << parse_project(line)
      when /.*Format Version [\d\.]+/
        then @format_version = parse_version(line)
      when /^VisualStudioVersion/
        then @visual_studio_version = parse_version(line)
      when /^MinimumVisualStudioVersion/
        then @minimum_visual_studio_version = parse_version(line)
      end
    end

    def chop(s)
      s.gsub('"', '')
    end

    def parse_version(s)
      s.gsub(/[\d\.]+/).first
    end

    def parse_project(s)
      items = s.gsub(/".*?"/).to_a
      { id: chop(items[3]), name: chop(items[1]), file: chop(items[2]) }
    end
  end
end
