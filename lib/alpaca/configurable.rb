require 'yaml'

module Alpaca
  # The *Configurable* module provides methods to:
  # - configure classes that include it from yaml files or hash
  # - get configured attributes as arguments for later usage
  module Configurable
    # Configures class with file or config provided as argument
    #
    #   a.configure(hello: 'world')
    #       # => "#<A:0x000000036a6fc8 @hello=\"world\""
    #   b.configure('hello_world.yml')
    #       # => "#<B:0x00000003987ee0 @hello=\"world\""
    def configure(file_or_config)
      if file_or_config.is_a?(String)
        config = YAML.load(File.open(file_or_config))
      elsif file_or_config.is_a?(Hash)
        config = file_or_config
      else
        fail 'wrong configuration'
      end
      parse_config config
    end

    # Provides value for attribute by name
    #
    # +key+:: name of the attribute
    # useful for providing formattors for attributes
    def get_arg_value(key)
      val = send key
      val.to_s
    end

    # Converts attribute to an argument
    #
    # +key+:: name of the attribute
    # +prefix+:: prefix for the argument ('/' or '-')
    # +name+:: name of the attribute
    # +separator+:: separator of argument name and value (empty by default)
    # +switch+:: true if argument need no value (true by default)
    def attr_to_arg(key, prefix, name, separator = nil, switch = true)
      if respond_to?(key) && (send key)
        arg = %W(#{prefix} #{name})
        arg += %W(#{separator}) if separator && !switch
        arg += %W(#{get_arg_value key}) unless switch
        [arg.join('')]
      else
        []
      end
    end

    # Returns converted attribute to an argument without asking an
    # argument name, it will be produced by camilizing(hi_there -> HiThere)
    # of attribute name
    #
    # +key+:: name of the attribute
    # +prefix+:: prefix for the argument ('/' or '-')
    # +separator+:: separator of argument name and value (empty by default)
    # +switch+:: true if argument need no value (true by default)
    def attr_to_camel_arg(key, prefix, separator = nil, switch = true)
      attr_to_arg(key, prefix, camelize(key), separator, switch)
    end

    # Returns all attributes configured with *configure* method
    # converted to arguments
    #
    # +prefix+:: prefix for the argument ('/' or '-')
    # +separator+:: separator of argument name and value (empty by default)
    def all_configured_attributes_to_camel_args(prefix, separator = nil)
      args = []
      if @configured
        @configured.each do |p|
          key = p[:key].to_s
          switch = p[:switch]
          args += (attr_to_camel_arg key, prefix, separator, switch)
        end
      end
      args
    end

    # Parses hash and populate class attributes for each key in the hash
    #
    # +config+:: hash with class configuration(extension)
    def parse_config(config)
      config.each do |key, value|
        self.class.send(:attr_accessor, key) unless respond_to?("#{key}=")
        send "#{key}=", value
        mark_as_configured key, value
      end
    end

    # Marks attribute as configured so it can be used with
    # *all_configured_attributes_to_camel_args* method
    #
    # +key+:: name of the attribute
    # +value+:: value of the attribute
    def mark_as_configured(key, value)
      (@configured ||= []) << { key: key, switch: switch?(value) }
    end

    # Returns true if value is a switch(Boolean) and false otherwise
    def switch?(value)
      value == true || value == false
    end

    # Returns string converted from underscore case(hi_there_it_is_underscore)
    # to camel case(HiThereItIsCamel)
    def camelize(str)
      str.split('_').map(&:capitalize).join
    end

    # Removes values from configured attributes
    # and unmark then from configured
    def clear_configuration
      return nil unless @configured
      @configured.each do |a|
        remove_instance_variable('@' + a[:key].to_s).to_sym
      end
      @configured = nil
    end
  end
end
