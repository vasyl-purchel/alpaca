require 'alpaca/entities/config'
require 'yaml'

module Alpaca
  # The *ConfigFactory* module provides access to
  # configurations.
  # It uses Singelton pattern to prevent from loading
  # configurations few times
  class Configuration
    DEFAULT = File.join(Alpaca::LIB_DIR, 'alpaca/data/alpaca.yml')
    GLOBAL = File.expand_path('~/.alpaca.yml')
    CLEAN_CONFIGURATION_KEY = 'clean_configuration'
    LOCAL_CONFIGURATION_KEY = 'local_config'

    CONFIGURATION_VARIABLES = [
      '#{SOLUTION_DIRECTORY}',
      '#{SOLUTION_NAME}'
    ]

    def initialize(hash = nil)
      return @configuration = hash.dup if hash
      default = YAML.load(File.open(DEFAULT))
      global = YAML.load(File.open(GLOBAL))
      @configuration = merge(default, global)
    end

    def for(solution)
      configuration = detokenize(@configuration, solution)
      local_configuration_dir = @configuration.fetch(LOCAL_CONFIGURATION_KEY)
      local_configuration_dir = local_configuration_dir
    end

    private

    def merge(h1, h2)
      return clean(h2) if clean?(h2)
      h1.merge(h2) { |_, o, n| o.is_a?(Hash) ? merge(o, n) : n }
    end

    def clean?(hash)
      hash.key? CLEAN_CONFIGURATION_KEY
    end

    def clean(hash)
      hash.delete CLEAN_CONFIGURATION_KEY
      hash
    end

    def detokenize(config, solution)
      config = detokenize_os(config) if config.is_a? Hash
      return detokenize_string(config, solution) if config.is_a? String
      return config.map { |i| detokenize(i, solution) } if config.is_a? Array
      return detokenize_hash(config, solution) if config.is_a? Hash
      config
    end

    def detokenize_os(value)
      (value.is_a?(Hash) && value[Os.os]) value[Os.os] : value
    end

    def detokenize_string(value, solution)
      value = value.gsub('#{SOLUTION_DIRECTORY}', solution.folder)
      value.gsub('#{SOLUTION_NAME}', File.basename(solution.file, '.*'))
    end

    def detokenize_hash(value, solution)
      value.keys.each { |key| value[key] = detokenize(value[key], solution) }
      value
    end
  end

  class SolutionConfiguration
    LC_KEY = 'local_config'

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
