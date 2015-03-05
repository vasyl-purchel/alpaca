require 'alpaca/tools/console_tool_wrapper'
require 'alpaca/tools/console_application'

module Alpaca
  # The *OpenCover* class provides access to OpenCover
  class OpenCover
    include ConsoleToolWrapper
    include ConsoleApplication

    def inner_option_formatter(name, value, switch)
      switch ? "-#{name}" : "-#{name}:#{encapsulate(value)}"
    end
  end
end
