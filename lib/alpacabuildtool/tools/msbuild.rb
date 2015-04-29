require 'alpacabuildtool/tools/tool'

module AlpacaBuildTool
  ##
  # MSBuild provides access to MSBuild.exe tool
  class MSBuild < Tool
    ##
    # Build *.sln file
    #
    # +file+:: solution file with absolute path
    # +debug+:: set to build with debug configuration
    def build(file, debug = false)
      config = @configuration['options'].dup
      config['Property'] ||= {}
      config['Property']['Configuration'] = debug ? 'Debug' : 'Release'
      call([config, file])
    end

    private

    def format_option(name, value, switch)
      case value
      when Array then value = value.join(';')
      when Hash then value = value.map { |k, v| "#{k}=#{v}" }.join(';')
      end
      super name, value, switch
    end
  end
end
