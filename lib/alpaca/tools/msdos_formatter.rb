module Alpaca
  # The *MsDosFormatter* module provides partial implementation
  # of formatting MS-Dos style console application options
  module MsDosFormatter
    def inner_option_formatter(name, value, switch)
      switch ? "/#{name}" : "/#{name}:#{encapsulate(value)}"
    end
  end
end
