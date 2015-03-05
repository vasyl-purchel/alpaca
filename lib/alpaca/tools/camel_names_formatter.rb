module Alpaca
  # The *CamelNamesFormatter* module provides options formatting
  # in nuget.exe style (-ConfigFile file)
  module CamelNamesFormatter
    def format_option(name, value)
      super(camelize(name.to_s), value)
    end

    def camelize(str)
      str.split('_').map(&:capitalize).join
    end

    def inner_option_formatter(name, value, switch)
      switch ? "-#{name}" : "-#{name} #{encapsulate(value)}"
    end
  end
end
