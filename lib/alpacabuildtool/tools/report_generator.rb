require 'fileutils'
require 'alpacabuildtool/tools/tool'

module AlpacaBuildTool
  ##
  # ReportGenerator provides access to ReportGenerator.exe tool
  class ReportGenerator < Tool
    ##
    # Convert OpenCover results
    def convert
      options = @configuration['options'] || {}
      unless File.exist? options['reports']
        return log.warn 'no coverage results found'
      end
      FileUtils.makedirs options['targetdir'] if options['targetdir']
      call([options])
    end

    private

    def format_option(name, value, switch)
      switch ? "-#{name}" : "-#{name}:#{encapsulate(value)}"
    end
  end
end
