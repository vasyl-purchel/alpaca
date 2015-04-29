require 'alpacabuildtool/tools/nunit_orange'
require 'alpacabuildtool/tools/report_generator'
require 'alpacabuildtool/managers/package_manager'

module AlpacaBuildTool
  ##
  # ReportManager provides methods to convert test results to reports
  class ReportManager
    ##
    # Creates an instance
    #
    # +solution+:: solution to be used to configure reports manager
    def initialize(solution)
      package_manager = PackageManager.new(solution)
      @test_tool = package_manager.get('NUnitOrange')
      @coverage_tool = package_manager.get('ReportGenerator')
    end

    ##
    # Convert results to reports
    #
    # +type+:: type of results to be converted(tests, coverage, all)
    def convert(type)
      case type
      when 'tests' then @test_tool.convert
      when 'coverage' then @coverage_tool.convert
      when 'all'
        @test_tool.convert
        @coverage_tool.convert
      end
    end
  end
end
