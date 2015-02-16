require 'alpaca/base/base_formatter'

module Alpaca
  # The *Attribute* class provides methods around attributes
  class Attribute
    attr_accessor :name, :value

    # Creates instance of class
    #
    # +name+:: attribute name
    # +[value]+:: value of the attribute(nil by default)
    def initialize(name, value = nil)
      @name, @value = name, value
    end

    # Converts attribute to an argument
    #
    # +prefix+:: prefix for the argument ('/' or '-')
    # +separator+:: separator of argument name and value (empty by default)
    # +[formatter]+:: class that implements format(name, value)
    # (CamelizeNameFormatter by default)
    def to_arg(prefix, separator, formatter = nil)
      formatter ||= BaseFormatter.new
      n, v = formatter.format(@name, @value)
      arg = %W(#{prefix} #{n})
      arg += %W(#{separator} #{v}) unless switch?
      arg.join('')
    end

    private

    # Returns true if value is a switch(Boolean) and false otherwise
    def switch?
      @value.nil? || @value == true || @value == false
    end
  end
end
