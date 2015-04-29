require 'fileutils'
require 'alpacabuildtool/tools/tool'

module AlpacaBuildTool
  # tool
  class Nuget < Tool
    def restore(solution_file)
      run_command 'restore', solution_file
    end

    def install(package,
                outputdir = nil,
                prerelease = false,
                exclude_version = false,
                source = nil)
      extra_options = {}
      extra_options['OutputDirectory'] = outputdir if outputdir
      extra_options['Prerelease'] = prerelease if prerelease
      extra_options['ExcludeVersion'] = exclude_version if exclude_version
      extra_options['Source'] = source if source
      run_command 'install', package, extra_options
    end

    def pack(nuspec_or_project, configuration = nil)
      extra_options = {}
      extra_options['Prop'] = "Configuration=#{configuration}" if configuration
      run_command 'pack', nuspec_or_project, extra_options
    end

    def push(package, source)
      run_command 'install', package, 'Source' => source
    end

    private

    def run_command(command, arguments, extra_options = nil)
      options = @configuration['options'] || {}
      options.merge!((@configuration['commands'] || {})[command] || {})
      options.merge! extra_options if extra_options
      output_dir = options['OutputDirectory']
      FileUtils.makedirs output_dir if output_dir
      call([command, arguments, options].flatten)
    end

    def format_option(name, value, switch)
      switch ? "-#{name}" : "-#{name} #{encapsulate(value)}"
    end
  end
end
