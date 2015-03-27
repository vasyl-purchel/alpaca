require 'alpaca/tools/console_command_suit'
require 'alpaca/tools/camel_names_formatter'

module Alpaca
  # The *Nuget* class provides access to nuget
  class Nuget
    include ConsoleCommandSuit
    include CamelNamesFormatter

    def initialize(configuration)
      @configuration = configuration
      super(configuration.fetch('exe'))
    end

    def restore(solution_file)
      execute_with_options('restore', [solution_file])
    end

    private

    def execute_with_options(command, arguments)
      execute({},
              command,
              @configuration.fetch('commands')[command] || {},
              arguments)
    end
  end
end
