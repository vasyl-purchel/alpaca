require 'alpacabuildtool/entities/nuspec'
require 'alpacabuildtool/package_types/project_package'
require 'alpacabuildtool/package_types/tool_package'
require 'alpacabuildtool/tools/nuget'
require 'alpacabuildtool/tools/git'
require 'fileutils'

module AlpacaBuildTool
  ##
  # PackageManager provides package management methods for solution
  class PackageManager < Nuget
    ##
    # Defines where packages used by alpaca should be downloaded
    DOWNLOAD_DIR = File.join(File.expand_path('~'), '.download/')

    ##
    # Creates an instance
    # Use Nuget as package management tool
    #
    # +solution+:: solution to be used to configure build manager and to be
    # used further
    def initialize(solution)
      @solution = solution
      super(@solution.configuration['Nuget'])
    end

    ##
    # Returns named tool configured from current solution
    #
    # +name+:: tool name
    # +*args+:: arguments for tool creation
    #
    #    package_manager.get('NUnit')
    #    # => #<AlpacaBuildTool:NUnit **>
    #    package_manager.get('OpenCover', @test_tool)
    #    # => #<AlpacaBuildTool:OpenCover @tool=..NUnit..**>
    def get(name, *args)
      config = @solution.configuration[name]
      AlpacaBuildTool.const_get(name).new(config, *args) do
        exe_pattern = File.join(DOWNLOAD_DIR, '**', config['exe'])
        unless Dir.glob(exe_pattern).any?
          id, pre = config['package_id'], config['pre_release'] || false
          install(id, DOWNLOAD_DIR, pre)
        end
        Dir.glob(exe_pattern).first
      end
    end

    ##
    # Restore packages for solution
    def restore_packages
      if Dir.glob(File.dirname(@solution.file) + '/**/packages.config').empty?
        log.info 'no packages.config discovered'
        return
      end
      restore(@solution.file)
    end

    ##
    # Create and push if requested nuget package
    #
    # +config+:: package configuration from solution local configuration
    # +version+:: package version to be created
    # +options+:: hash with packaging options
    # <tt>options[:debug] = true</tt> is to create packages from debug mode<br\>
    # <tt>options[:push] = true</tt> is to push packages after they are created
    # <br\>
    # <tt>options[:force] = true</tt> is to create/push packages even if it has
    # no changes
    def create_package(config, version, options)
      config = generate_config(config, version)
      project = @solution.project(config['project'])
      changes, changelog = package_changes(config, project.dir)
      log.info "#{config['id']} unchanged..." unless changes
      return unless changes || options[:force]
      generate_package(project, config, options[:debug], changelog)
      push_packages(config) if options[:push]
    end

    private

    def generate_config(config, version)
      common = @solution.configuration['all_packages'] || {}
      common.merge(config).merge('version' => version)
    end

    def package_changes(config, project_dir)
      FileUtils.rm_rf File.join(DOWNLOAD_DIR, config['id'])
      begin
        changes, changelog = latest_package_changes(config, project_dir)
      rescue
        changes = Git.changes(project_dir)
      end
      new_changes = "#{Git.revision}\n---#{config['version']}---\n#{changes}\n"
      [changes != '', new_changes + (changelog || ['']).reduce(:+)]
    end

    def latest_package_changes(config, project_dir)
      install(config['id'], DOWNLOAD_DIR, config['version'].include?('-'),
              true, config['source'])
      file = File.join(DOWNLOAD_DIR, config['id'], 'CHANGES.txt')
      changelog = IO.readlines(file)
      commit_id = changelog.shift.gsub(/\n/, '')
      [Git.changes(project_dir, commit_id), changelog]
    end

    def generate_package(project, config, debug, changelog)
      package = typed_package(config['type'], config['id'], project, debug)
      write_mandatory_files(package, config, changelog)
      write_optional_file(package.files[2], config)
      pack(*package.options)
    end

    def typed_package(type, id, project, debug)
      AlpacaBuildTool.const_get("#{type.capitalize}Package")
        .new(id, project, debug)
    end

    def write_mandatory_files(package, config, changelog)
      File.write(package.files[0], Nuspec.new(config, package.add_files?).to_s)
      File.write(package.files[1], changelog)
    end

    def write_optional_file(file, config)
      File.write(file, config['readme']) if config['readme']
    end

    def push_packages(config)
      output_dir = @configuration['commands']['pack']['OutputDirectory']
      file = File.join(output_dir, "#{config['id']}.#{config['version']}")
      push("#{file}.nupkg", config['source'])
      symbols = "#{file}.symbols.nupkg"
      push(symbols, config['symbol_source']) if File.exist?(symbols)
    end
  end
end
