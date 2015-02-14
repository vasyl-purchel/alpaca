require_relative 'configurable'
require_relative 'msbuild_attribute_formatter'

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
        formatter = MSBuildAttributeFormatter.new
        args += configured_attributes_as_arguments('/', ':', formatter)
        args
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
          configure_attribute 'property', name => value
        end
      end
    end
  end
end
