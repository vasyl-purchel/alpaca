require 'alpaca/base/base_formatter'

module Alpaca
  # The *CamelizeNameFormatter* class provides format for name value pairs
  # by camelizing(hello_world -> HelloWorld) name
  class CamelizeNameFormatter < BaseFormatter
    # Returns [name, value] with camelized name and value.to_s
    def format(name, value)
      super(camelize(name.to_s), value)
    end

    private

    # Returns string converted from underscore case(hi_there_it_is_underscore)
    # to camel case(HiThereItIsCamel)
    def camelize(str)
      str.split('_').map(&:capitalize).join
    end
  end
end
