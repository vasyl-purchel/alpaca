require 'alpaca/tools/console_tool'
require 'alpaca/tools/base_formatter'

module Alpaca
  # The *ConsoleApplication* module provides simple access to
  # console applications by providing standartized interface
  module ConsoleApplication
    include ConsoleTool
    include BaseFormatter

    def execute(options, arguments)
      (args = []) << options.map { |o| format_option(o[0], o[1]) }
      (args ||= []) << arguments
      super(args)
    end
  end
end
