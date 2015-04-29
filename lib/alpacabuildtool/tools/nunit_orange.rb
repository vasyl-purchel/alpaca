require 'fileutils'
require 'alpacabuildtool/tools/tool'

module AlpacaBuildTool
  ##
  # NUnitOrange provides access to NUnitOrange.exe tool
  class NUnitOrange < Tool
    ##
    # Convert NUnit test results
    def convert
      input = @configuration['input']
      return log.warn 'no nunit test results found' unless File.exist? input
      FileUtils.makedirs File.dirname(@configuration['output'])
      output = @configuration['output']
      call([input, output])
    end
  end
end
