require 'alpacabuildtool/tools/tool'

module AlpacaBuildTool
  ##
  # Wrapper represents console tools that execute other console tools inside
  # their own process (like OpenCover, Ssh...)
  class Wrapper < Tool
    ##
    # Creates an instance
    # Overrides Tool initialization by adding tool that should be executed later
    #
    # +configuration+:: wrapper tool configuration
    # +tool+:: tool to be used inside wrapper tool
    def initialize(configuration, tool)
      super(configuration)
      @tool = tool.dup
      wrap_tool
    end

    ##
    # Execute wrapper tool with arguments
    #
    # +args+:: wrapper tool arguments
    # requires &block to be executed against inner tool
    #
    #   wrapper.call([debug: true]) do |tool|
    #      tool.call(['file.cs', {c: true, type: 'test'}])
    #   end
    #   # >> wrapper.exe /target:'tool.exe' /targetargs:'file.cs /c /type:test'
    #   # /debug
    def call(args)
      yield @tool
      @target = encapsulate(@tool.exe)
      @target_args = encapsulate(@tool.arguments)
      super(args)
    end

    private

    def wrap_tool
      @tool.instance_eval do
        def call(args)
          @arguments = format_arguments(args).join ' '
        end
        self.class.__send__(:attr_reader, 'exe')
        self.class.__send__(:attr_reader, 'arguments')
      end
    end

    def format_arguments(arguments)
      super arguments.map { |arg| detokenize_tool arg }
    end

    def detokenize_tool(object)
      if object.is_a? String
        return object.gsub('#{EXE}', @target).gsub('#{ARGS}', @target_args)
      end
      if object.is_a? Hash
        object.keys.each do |key|
          object[key] = detokenize_tool(object[key])
        end
      end
      object
    end
  end
end
