require 'alpaca/tools/console_tool'

module Alpaca
  # The *ConsoleToolWrapper* module provides usage for
  # tools like Ssh or OpenCover that takes other tools as
  # arguments or parameters and run them inside some wrapper
  module ConsoleToolWrapper
    include ConsoleTool

    def initialize(exe, tool)
      @exe, @tool = exe, tool
    end

    def execute(args)
      wrap_tool
      yield @tool
      unwrap_tool
      @target = encapsulate(@tool.system_call[:exe])
      @target_args = encapsulate(@tool.system_call[:args])
      super(args.flatten.map { |a| detokenize_tool a })
    end

    def wrap_tool
      @tool.instance_eval 'alias original run'
      @tool.instance_eval do
        def run(call)
          @system_call = { exe: @exe, args: call.gsub(@exe, '') }
        end
        self.class.__send__(:attr_accessor, 'system_call')
      end
    end

    def unwrap_tool
      @tool.instance_eval 'alias run original'
    end

    def detokenize_tool(str)
      if str.is_a? String
        str.gsub('#{EXE}', @target).gsub('#{ARGS}', @target_args)
      else
        str
      end
    end
  end
end
