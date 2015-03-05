require 'alpaca/entities/config'
require 'yaml'

module Alpaca
  # The *ConfigFactory* module provides access to
  # configurations.
  # It uses Singelton pattern to prevent from loading
  # configurations few times
  module ConfigFactory
    # The *Configurations* class provides access to
    # configurations and created for internal usage for
    # singelton pattern
    class Configurations
      GC_FILE = '/alpaca/data/alpaca.yml'

      # Provides instance created only once
      def self.instance
        @__instance__ ||= new
      end

      # Initializes configurations by loading global configuration
      def initialize
        gc = File.join(Alpaca::LIB_DIR + GC_FILE)
        @config = YAML.load(File.open(gc))
        @factory = {}
      end

      # Provides access to global configuration by name of configuration entry
      # or to overriden global configuration by local one for solution
      #
      # +name+: name of configuration entry
      # +[solution]+: Solution object to search for local configuration from
      def [](name, solution = nil)
        return Config.new(@config[name]) unless solution
        @factory[solution.file] ||= Config.new(@config.dup, solution)
        @factory[solution.file][name]
      end
    end

    # Provides access to configuration with using single instantiation of
    # configuration for global and each solution used
    def self.[](name, solution = nil)
      Configurations.instance[name, solution]
    end
  end
end
