module Alpaca
  # The *UnixFormatter* module provides partial implementation
  # of formatting Unix style console application options
  module UnixFormatter
    def inner_option_formatter(name, value, switch)
      name = (name.to_s.length == 1 ? '-' : '--') + name.to_s
      switch ? name : "#{name} #{encapsulate(value)}"
    end
  end
end
