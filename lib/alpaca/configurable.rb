require 'yaml'
require 'pathname'
require_relative 'errors'
require_relative 'attribute'

module Alpaca
  # The *Configurable* module provides methods to:
  # - configure classes that include it from yaml files or hash
  # - get configured attributes as arguments for later usage
  module Configurable
    # Configures class with file or config provided as argument
    #
    #   a.configure(hello: 'world')
    #       # => "#<A:0x000000036a6fc8 @hello=\"world\" ..."
    #   b.configure('hello_world.yml')
    #       # => "#<B:0x00000003987ee0 @hello=\"world\" ..."
    def configure(file_or_config, config_dir_name = '')
      unless file_or_config.is_a?(Hash) || file_or_config.is_a?(String)
        fail Errors::ConfigurationIsNeitherFileNorHash
      end
      if file_or_config.is_a?(Hash) then config = file_or_config
      elsif file_or_config.is_a?(String)
        file = find_config(file_or_config, config_dir_name)
        fail Errors::ConfigNotFound if file.nil?
        config = YAML.load(File.open(file))
      end
      config.each { |k, v| configure_attribute(k, v) }
    end

    # Configures attribute and mark it as configured so it can be used with
    # *configured_attributes_as_arguments* and *clear_configuration* methods
    #
    # +key+:: name of the attribute
    # +value+:: value of the attribute
    def configure_attribute(key, value)
      self.class.send(:attr_accessor, key) unless respond_to?("#{key}=")
      send "#{key}=", value
      (@attributes ||= []) << Attribute.new(key, value)
    end

    # Removes values from configured attributes
    # and unmark then from configured
    def clear_configuration
      return nil unless @attributes
      @attributes.each do |a|
        remove_instance_variable('@' + a.name.to_s).to_sym
      end
      @attributes = nil
    end

    # Returns all attributes configured with *configure* method
    # converted to arguments
    #
    # +prefix+:: prefix for the argument ('/' or '-')
    # +separator+:: separator of argument name and value (empty by default)
    # +[formatter]+:: fromatter for attributes (nil by default)
    def configured_attributes_as_arguments(prefix, separator, formatter = nil)
      return [] unless @attributes
      @attributes.map { |a| a.to_arg(prefix, separator, formatter) }
    end

    # Returns path to configuration directory by a reverse searching from
    # the base directory back to the filesystem's root directory
    #
    # +name+:: name of config directory
    # +[config_dir]+:: base config directory ('' by default)
    # +[dir]+:: base directory to start search from(current working
    # directory by default)
    def find_config(name, config_dir = '', cur = Pathname.new('.'))
      file = File.join(cur.expand_path, config_dir, name)
      return file if File.exist?(file)
      return nil if cur.expand_path.root?
      find_config(name, config_dir, cur.parent)
    end
  end
end
