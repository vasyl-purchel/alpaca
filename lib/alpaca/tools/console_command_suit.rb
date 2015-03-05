require 'alpaca/tools/console_tool'
require 'alpaca/tools/base_formatter'

module Alpaca
  # The *CommandLineSuit* module provides simple access to
  # console command suit
  module ConsoleCommandSuit
    include ConsoleTool
    include BaseFormatter

    def execute(global, command, options, arguments)
      (args = []) << global.map { |o| format_option(o[0], o[1]) }
      (args ||= []) << command
      args << options.map { |o| format_option(o[0], o[1]) }
      args << arguments
      super(args)
    end
  end
end
