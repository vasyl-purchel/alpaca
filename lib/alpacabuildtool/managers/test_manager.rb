require 'alpacabuildtool/tools/nunit'
require 'alpacabuildtool/tools/open_cover'
require 'alpacabuildtool/managers/package_manager'

module AlpacaBuildTool
  ##
  # TestManager provides methods to test *.sln solutions
  class TestManager
    ##
    # Creates an instance
    #
    # +solution+:: solution to be used to configure test manager
    def initialize(solution)
      package_manager = PackageManager.new(solution)
      @test_tool = package_manager.get('NUnit')
      @coverage_tool = package_manager.get('OpenCover', @test_tool)
    end

    ##
    # Test list of projects
    #
    # +test_projects+:: list of projects with tests
    # +coverage+:: set to run coverage
    # +debug+:: set to run tests with debug configuration
    def test(test_projects, coverage = false, debug = false)
      test_projects.each do |project|
        if coverage
          @coverage_tool.call { |tool| tool.test(project.file, debug) }
        else
          @test_tool.test(project.file, debug)
        end
      end
    end
  end
end
