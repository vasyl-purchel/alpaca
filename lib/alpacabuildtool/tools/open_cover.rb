require 'fileutils'
require 'alpacabuildtool/tools/wrapper'

module AlpacaBuildTool
  ##
  # OpenCover provides access to OpenCover.exe tool
  class OpenCover < Wrapper
    ##
    # Runs coverage by running inner tool
    #
    # accepts &block for inner tool
    #
    #    coverage_tool = package_manager.get('OpenCover', test_tool)
    #    coverage_tool.call do |tool|
    #      tool.test(project.file, debug)
    #    end
    def call(&block)
      options = @configuration.fetch('options')
      FileUtils.makedirs File.dirname(options['output']) if options['output']
      super([options], &block)
    end

    private

    def format_option(name, value, switch)
      switch ? "-#{name}" : "-#{name}:#{encapsulate(value)}"
    end
  end
end
