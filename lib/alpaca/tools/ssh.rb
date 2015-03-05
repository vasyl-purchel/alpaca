require 'alpaca/tools/console_tool_wrapper'
require 'alpaca/tools/console_application'

module Alpaca
  # The *Ssh* class provides access to ssh
  class Ssh
    include ConsoleToolWrapper
    include ConsoleApplication

    def initialize(tool)
      super('ssh', tool)
    end

    def execute(options, user, host)
      super(options, ["#{user}@#{host}", '#{EXE} #{ARGS}'])
    end

    def inner_option_formatter(name, value, switch)
      switch ? "-#{name}" : "-#{name} #{encapsulate(value)}"
    end
  end
end
