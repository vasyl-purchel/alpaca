require 'alpaca/tools/console_application'
require 'alpaca/tools/unix_formatter'

module Alpaca
  # The *NUnit* class provides access to nunit-console.exe
  class NUnit
    include ConsoleApplication
    include UnixFormatter
  end
end
