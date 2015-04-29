require 'alpacabuildtool/tools/msbuild'
require 'alpacabuildtool/managers/package_manager'

module AlpacaBuildTool
  ##
  # BuildManager provides methods to build *.sln solutions
  class BuildManager
    ##
    # Creates an instance
    #
    # +solution+:: solution to be used to configure build manager and to be
    # built later
    def initialize(solution)
      @solution = solution
      @package_manager = PackageManager.new(@solution)
      @build_tool = MSBuild.new(@solution.configuration['MSBuild'])
    end

    ##
    # Build solution
    #
    # +debug+:: set to build in debug mode
    # +update_version:: set to update AssemblyInfo.cs files for all solution
    # projects
    def build(debug, update_version)
      @package_manager.restore_packages
      build_version = @solution.build_version
      @solution.update_projects_version(build_version) if update_version
      @build_tool.build(@solution.file, debug)
    end
  end
end
