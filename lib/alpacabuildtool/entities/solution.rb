require 'alpacabuildtool/log/log'
require 'alpacabuildtool/configuration'
require 'alpacabuildtool/entities/project'
require 'alpacabuildtool/versioning/versioning'

module AlpacaBuildTool
  ##
  # Solution provides solution representation and it's configuration storage
  class Solution
    include Log

    attr_reader :file, :dir, :projects

    ##
    # Creates instance from *.sln file
    # Initializes solution's semantic version and absolute path to it's file
    #
    # +file+:: absolute or relative path to *.sln file
    def initialize(file)
      @file = File.expand_path(file)
      @dir = File.dirname(@file)
      @semver = Versioning.find(@dir)
    end

    ##
    # Overrides string representation. Spawned to multiple lines
    def to_s
      s = '------------'
      s += "\nFile: #{@file}"
      s += "\nVersion: #{build_version}"
      s += "\nProjects:" unless projects.empty?
      projects.each { |p| s += "\n\t#{p}" }
      s + "\n------------"
    end

    ##
    # Returns Configuration object for current solution (initialized only once)
    def configuration
      @configuration ||= Configuration.new(self)
    end

    ##
    # Returns array of it's projects (initialized only once)
    def projects
      return @projects if @projects
      @projects = []
      IO.readlines(@file).each do |line|
        @projects << Project.new(line, @dir) if /^Project.*\.csproj/ =~ line
      end
    end

    ##
    # Returns specific project by it's name
    #
    # +name+:: project's name
    def project(name)
      @projects.find { |p| p.name == name }
    end

    ##
    # Updates all projects AssemblyInfo.cs files with specific version
    #
    # +version+:: version to be stored in AssemblyInfo.cs files
    def update_projects_version(version)
      projects.each do |project|
        project.update_version version
      end
    end

    ##
    # Returns array of projects that correspondes to specific type
    #
    # +type+:: type of project defined in configuration project_types
    def specific_projects(type)
      types = configuration['project_types'].dup
      types.select! { |t| t['type'] == type } unless type == 'all'
      projects.select do |project|
        types.any? { |t| project.name.include? t['name'] }
      end
    end

    ##
    # Returns true if solution is marked as *nobuild*
    def no_build?
      solution_name = File.basename(@file, '.*')
      (configuration['no_build'] || []).each do |tag|
        return true if solution_name.include?(tag)
      end
      false
    end

    ##
    # Returns current build version
    def build_version
      @semver.to_s '%M.%m.%p'
    end

    ##
    # Returns current package version
    def package_version
      @semver.to_s '%M.%m.%p%s'
    end
  end
end
