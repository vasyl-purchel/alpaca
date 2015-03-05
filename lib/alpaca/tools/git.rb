require 'alpaca/tools/console_command_suit'
require 'alpaca/tools/camel_names_formatter'

module Alpaca
  # The *Git* class provides access to git
  class Git
    include ConsoleCommandSuit
    include CamelNamesFormatter

    def initialize
      super('git')
    end
  end
end
