module AlpacaBuildTool
  ##
  # ProjectPackage provides configuration of normal nuget packages created
  # from projects
  class ProjectPackage
    ##
    # Creates an instance
    #
    # +package_id+:: not used in current class, but need to be here for
    # consistent interface with other package types
    # +project+:: project to be used to create a package
    # +debug+:: is debug configuration should be used to create a package
    def initialize(_, project, debug)
      @nuspec_file = File.join(project.dir, "#{project.name}.nuspec")
      @readme_file = File.join(project.dir, 'README.txt')
      @changelog_file = File.join(project.dir, 'CHANGES.txt')
      @file = project.file
      @debug = debug
    end

    ##
    # Returns array of files: *.nuspec, CHANGELOG.txt, README.txt
    def files
      [@nuspec_file, @changelog_file, @readme_file]
    end

    ##
    # Returns options to be passed to Nuget.pack
    def options
      [@file, @debug ? 'Debug' : 'Release']
    end

    ##
    # Returns true so Nuspec file creation process will store readme and
    # changelog files into <files/> entry
    #
    # This is required for normal packages as they are created from *.csproj
    # but adding them for :tool packages cause missing all other files as
    # :tool package is created from folder and not *.csproj
    def add_files?
      true
    end
  end
end
