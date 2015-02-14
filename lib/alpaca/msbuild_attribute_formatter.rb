require_relative 'camelize_name_formatter'

module Alpaca
  module MSBuild
    # The *MSBuildAttributeFormatter* class provides format for
    # MSBuild attributes
    class MSBuildAttributeFormatter < CamelizeNameFormatter
      # Returns [name, value] by using CamelizeNameFormatter::format
      # with value:
      # - [1, 2, 3] => "1;2;3"
      # - {key1: 'val1', key2: 'val2'} => "key1=val1;key2=val2"
      # - 'a' => "a"
      def format(name, value)
        new_value = value
        if value.is_a?(Array)
          new_value = value.join(';')
        elsif value.is_a?(Hash)
          new_value = value.map { |k, v| "#{k}=#{v}" }.join(';')
        end
        super(name, new_value)
      end
    end
  end
end
