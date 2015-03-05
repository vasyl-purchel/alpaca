require 'alpaca/tools/msdos_formatter'

module Alpaca
  # The *MSBuildFormatter* module provides partial implementation
  # of formatting MS-Dos style console application options for msbuild.exe
  module MSBuildFormatter
    include MsDosFormatter
    def format_option(name, value)
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
