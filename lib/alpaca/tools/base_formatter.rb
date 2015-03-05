module Alpaca
  # The *BaseFormatter* module provides basic partial implementation
  # for console tools
  module BaseFormatter
    def format_argument(object)
      encapsulate object
    end

    def format_option(name, value)
      switch = value.nil? || value == true || value == false
      inner_option_formatter name, value, switch
    end

    def encapsulate(object)
      (object.to_s.include? ' ') ? "\"#{object}\"" : object.to_s
    end
  end
end
