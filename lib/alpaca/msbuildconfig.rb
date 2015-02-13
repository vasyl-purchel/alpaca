require_relative 'configurable'

module Alpaca
  module MSBuild
    # The *Config* class provides method to:
    # - get arguments list for MSBuild command line tool
    class Config
      include Configurable

      attr_accessor :file

      # Creates instance of class
      #
      # +file+:: solution file with path to be compiled
      # +&block+:: accepts block where you can configure arguments
      #
      #   c = Alpaca::MSBuild::Config.new 'some.sln' do
      #     configure(target: %w(Clean Build))
      #   end
      #     # => #<***:Config:*** @file="some.sln", @target=["Clean", "Build"]>
      def initialize(file, &block)
        @file = file
        instance_eval(&block) if block_given?
      end

      # Provides string representation of the class
      # by joining all arguments with spaces togather
      def to_s
        args.join(' ').to_s
      end

      # Returns Array of all arguments that should be used with MSBuild.exe
      # for current configuration
      def args
        args = %W(#{file})
        args += all_configured_attributes_to_camel_args('/', ':')
        args
      end

      # Overrides _get_arg_value_ from Alpaca::Configurable module
      # to provide formatiing for Array and Hash attributes
      # (target and property)
      def get_arg_value(key)
        val = send key
        if val.is_a?(Array)
          val.join(';')
        elsif val.is_a?(Hash)
          val.map { |k, v| "#{k}=#{v}" }.join(';')
        else
          val.to_s
        end
      end

      # Set property
      # This is to update/set '/Propery:' parameter for
      # command line
      #
      # +name+:: property name
      # +value+:: property value
      def set_property(name, value)
        if @property
          @property[name] = value
        else
          @property = { name => value }
          mark_as_configured 'property', @property
        end
      end
    end
  end
end
