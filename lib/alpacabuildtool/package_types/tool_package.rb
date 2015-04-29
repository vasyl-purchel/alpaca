require 'fileutils'

module AlpacaBuildTool
  ##
  # ProjectPackage provides configuration of normal nuget packages created
  # from projects
  class ToolPackage
    ##
    # Defines workspace where files should be copied for further packaging
    # and where *.nuspec, readme and changelog should be created
    # For now it's ~/.workspace
    WORKSPACE = File.join(File.expand_path('~'), '.workspace/')

    ##
    # Creates an instance
    #
    # +package_id+:: package id so workspace is not messed up
    # +project+:: project to be used to create a package
    # +debug+:: is debug configuration should be used to create a package
    #
    # *It clean workspace/package_id folder and copy files from project/bin*
    def initialize(package_id, project, debug)
      workspace = File.join(WORKSPACE, package_id)
      FileUtils.rm_rf(workspace)
      FileUtils.makedirs(workspace + '/tools')
      tool_path = File.join(project.dir, 'bin', debug ? 'Debug' : 'Release')
      FileUtils.copy_entry(tool_path, workspace + '/tools')
      @nuspec_file = File.join(workspace, "#{package_id}.nuspec")
      @readme_file = File.join(workspace, 'README.txt')
      @changelog_file = File.join(workspace, 'CHANGES.txt')
    end

    ##
    # Returns array of files: *.nuspec, CHANGELOG.txt, README.txt
    def files
      [@nuspec_file, @changelog_file, @readme_file]
    end

    def options
      [@nuspec_file]
    end

    ##
    # Returns false so Nuspec file creation process will not store readme and
    # changelog files into <files/> entry
    #
    # This is required for tools packages as they are created from folder
    # and they will miss tool files if <files/> entry will exist in *.nuspec
    def add_files?
      false
    end
  end
end
