require 'yaml'

module Alpaca
  # The *Config* class contains configuration built around Hash
  # by overriding it with local solution configurations
  class Config
    LC_KEY = 'local_config'
    CLEAN_CONFIGURATION_KEY = 'clean_configuration'

    attr_reader :config

    # Creates new instance
    #
    # +yaml+: Hash with configuration
    # +[solution]+: Solution to seach for local config
    def initialize(yaml, solution = nil)
      if solution
        @config = detokenize(yaml, sln: solution.folder)
        Dir.glob(@config[LC_KEY]).each do |f|
          lc = YAML.load(File.open(f))
          lc = detokenize(lc, sln: solution.folder)
          @config = merge(@config, lc)
        end
      end
      @config ||= yaml
    end

    # Returns Config object that holds configuration for specific entry
    #
    # +name+: name of configuration entry
    def [](name)
      Config.new(@config[name] || {})
    end

    # Returns value of 'exe' entry in config and if it doesn't exist then fail
    def exe
      @config.fetch('exe')
    end

    # Returns value of 'options' entry in config or options for a command
    #
    # +[command]+: command name, if 'commands' entry doesn't exists
    # it will fail but if command not found then empty config returned
    def options(command = nil)
      if command
        @config.fetch('commands')[command] || {}
      else
        @config['options'] || {}
      end
    end

    # Returns new Config object that contains current configuration merged
    # with provided Hash
    #
    # +hash+: specific configuration entry
    def with(hash)
      Config.new(merge(@config.dup, hash))
    end

    # Returns value of 'global' entry in config
    def global
      @config['global']
    end

    # Provides map method same to Hash
    def map(&block)
      @config.map(&block)
    end

    private

    def detokenize(yaml, variables)
      yaml = detokenize_os(yaml) if yaml.is_a? Hash
      return detokenize_value(yaml, variables) if yaml.is_a? String
      if yaml.is_a? Hash
        yaml.keys.each { |k| yaml[k] = detokenize(yaml[k], variables) }
      elsif yaml.is_a? Array
        yaml = yaml.map { |i| detokenize(i, variables) }
      end
      yaml
    end

    def detokenize_value(value, variables)
      variables.each { |k, v| value = value.gsub("\#{#{k}}", v) }
      value
    end

    def detokenize_os(value)
      if value.is_a?(Hash) && value[Os.os]
        value[Os.os]
      else
        value
      end
    end

    def merge(h1, h2)
      return clean(h2) if clean?(h2)
      h1.merge(h2) { |_, o, n| o.is_a?(Hash) ? merge(o, n) : n }
    end

    def clean?(h)
      h.key? CLEAN_CONFIGURATION_KEY
    end

    def clean(h)
      h.delete CLEAN_CONFIGURATION_KEY
      h
    end
  end
end
