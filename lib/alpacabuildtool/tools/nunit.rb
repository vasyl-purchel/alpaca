require 'fileutils'
require 'alpacabuildtool/tools/tool'

module AlpacaBuildTool
  ##
  # NUnit provides access to nunit-console.exe tool
  class NUnit < Tool
    ##
    # Runs tests from project
    #
    # +project+:: project file with absolute path
    # +debug+:: set to run test with debug configuration
    def test(project, debug)
      options = @configuration['options']
      options['config'] = 'Debug' if debug
      FileUtils.makedirs options['work'] if options['work']
      FileUtils.makedirs File.dirname(options['output']) if options['output']
      call([options, project])
    end

    private

    def format_option(name, value, switch)
      name = (name.to_s.length == 1 ? '-' : '--') + name.to_s
      switch ? name : "#{name} #{encapsulate(value)}"
    end
  end
end
