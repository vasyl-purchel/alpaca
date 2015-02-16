module Alpaca
  # The *BaseFormatter* class provides format for name value pairs
  class BaseFormatter
    # Returns [name, value] as name.to_s and value.to_s
    def format(name, value)
      [name.to_s, (value.to_s.include? ' ') ? "\"#{value}\"" : value.to_s]
    end
  end
end
