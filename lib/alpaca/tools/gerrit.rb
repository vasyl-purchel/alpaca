require 'alpaca/tools/console_command_suit'
require 'alpaca/tools/unix_formatter'

module Alpaca
  # The *Gerrit* class provides access to gerrit command line
  class Gerrit
    include ConsoleCommandSuit
    include UnixFormatter

    def initialize
      super('gerrit')
    end
  end
end
