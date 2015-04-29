require 'alpacabuildtool/log/log'
require 'alpacabuildtool/entities/solution'
require 'alpacabuildtool/managers/build_manager'
require 'alpacabuildtool/managers/package_manager'
require 'alpacabuildtool/managers/test_manager'
require 'alpacabuildtool/managers/report_manager'

module AlpacaBuildTool
  ##
  # Application is a main entry point for CLI
  class Application
    include Log

    ##
    # Compiles solution [s]
    #
    # +pattern+:: pattern for solutions search
    # +options+:: hash with compilation options
    # <tt>options[:debug] = true</tt> is to compile solution in debug mode<br>
    # <tt>options[:update_version] = true</tt> is to update project versions
    # before compiling
    #
    #    app.compile('**/*.sln', debug: true, update_version: true)
    #    # => building found solutions in debug mode
    #    #    with updating project versions
    def compile(pattern, options)
      log.header 'Compile'
      each_solution(pattern) do |solution|
        build_manager = BuildManager.new(solution)
        build_manager.build(options[:debug], options[:update_version])
      end
    end

    ##
    # Run tests for solution [s]
    #
    # +pattern+:: pattern for solutions search
    # +options+:: hash with testing options
    # <tt>options[:debug] = true</tt> is to run tests in debug mode<br>
    # <tt>options[:coverage] = true</tt> is to run coverage<br>
    # <tt>options[:type] = 'all'</tt> is to run 'all' test types
    # ('all', 'unit', 'service')
    #
    #    app.test('**/*.sln', coverage: true, type: 'unit')
    #    # => running unit tests with coverage
    def test(pattern, options)
      log.header 'Test'
      each_solution(pattern) do |solution|
        test_projects = solution.specific_projects(options[:type])
        next log.info 'no tests discovered' if test_projects.empty?
        test_manager = TestManager.new(solution)
        test_manager.test(test_projects, options[:coverage], options[:debug])
      end
    end

    ##
    # Convert test results into reports for solution [s]
    #
    # +pattern+:: pattern for solutions search
    # +options+:: hash with reporting options
    # <tt>options[:type] = 'all'</tt> is to convert 'all' results into reports
    # ('all', 'tests', 'coverage')
    #
    #    app.report('**/*.sln', type: 'coverage')
    #    # => converting coverage results into html reports
    def report(pattern, options)
      log.header 'Report'
      each_solution(pattern) do |solution|
        report_manager = ReportManager.new(solution)
        report_manager.convert(options[:type])
      end
    end

    ##
    # Create packages for solution [s]
    #
    # +pattern+:: pattern for solutions search
    # +options+:: hash with packaging options
    # <tt>options[:debug] = true</tt> is to create packages from debug mode<br\>
    # <tt>options[:push] = true</tt> is to push packages after they are created
    # <br\>
    # <tt>options[:force] = true</tt> is to create/push packages even if it has
    # no changes
    #
    #    app.package('**/*.sln')
    #    # => creating only packages with changes in release mode without
    #    #    pushing them
    def package(pattern, options)
      log.header 'Package'
      each_solution(pattern) do |solution|
        version = solution.package_version
        package_manager = PackageManager.new(solution)
        (solution.configuration['packages'] || []).each do |package|
          package_manager.create_package(package, version, options)
        end
      end
    end

    ##
    # Release packages for solution [s]
    #
    # Updates .semver file to get release version if it is not release yet
    # Rebuilds solution and create release package
    # Changes are checked from last release package
    #
    # +pattern+:: pattern for solutions search
    # +options+:: hash with releasing options
    # <tt>options[:push] = true</tt> is to push packages after they are created
    # <br>
    # <tt>options[:force] = true</tt> is to create/push packages even if it has
    # no changes
    #
    #    app.release('**/*.sln')
    #    # => creating only packages with changes without pushing them
    def release(pattern, options)
      log.header 'Release'
      each_solution(pattern) do |solution|
        semver = Versioning.find(solution.dir)
        semver.release if semver.prerelease?
        Versioning.save semver
      end
      compile(pattern, debug: false, update_version: true)
      test(pattern, {})
      options[:debug] = false
      package(pattern, options)
    end

    ##
    # Update .semver files for solution [s]
    #
    # +pattern+:: pattern for solutions search
    # +options+:: hash with releasing options
    # <tt>options['dimension'] = :patch</tt> is to update version patch
    # (major, minor, patch, prerelease)
    #
    #    app.update('**/*.sln', 'dimension' => :minor)
    #    # => increase minor version in .semver by 1
    def update(pattern, options)
      log.header 'Update'
      each_solution(pattern) do |solution|
        semver = Versioning.find(solution.dir)
        semver.increase(options['dimension'].to_sym)
        Versioning.save semver
      end
    end

    ##
    # Update/create *~/.alpaca.conf*
    #
    # +properties+:: array of properties to store in global configuration
    # in format node1.node2.property=value
    #
    #    app.configure_global(['hello.world=yay'])
    #    # => produce yaml text in ~/.alpaca.conf:
    #    #    hello:
    #    #      world: yay
    def configure_global(properties)
      log.header 'Configure'
      Configuration.set(properties)
    end

    ##
    # Update/create *local configuration*
    #
    # +pattern+:: pattern for solutions search
    # +properties+:: array of properties to store in global configuration
    # in format node1.node2.property=value
    #
    #    app.configure_local('**/*.sln', ['hello.world=yay'])
    #    # => produce yaml text in .alpaca.conf for each solution:
    #    #    hello:
    #    #      world: yay
    def configure_local(pattern, properties)
      log.header 'Configure'
      Solutions.each(pattern) do |solution|
        log.puts "saving configuration for #{solution.name}"
        Configuration.new(solution).set(properties)
      end
    end

    private

    def each_solution(pattern)
      Dir.glob(pattern).each do |file|
        next unless File.file?(file) && file.end_with?('.sln')
        solution = Solution.new(file)
        log.puts solution
        next log.info 'no build solution' if solution.no_build?
        Dir.chdir(solution.dir) do
          yield solution
        end
      end
    end
  end
end
