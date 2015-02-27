module Alpaca
  # The *ConfigurationFactory* class represent factory
  # to get all configurations
  class ConfigurationFactory
    GC_FILE = '/alpaca/data/alpaca.yml'
    GC = File.join(GEM_DIR + GC_FILE)

    class Config
      def initialize(solution, global_config, local_config)
        lc = load(local_config, solution)
        @config = (lc ? merge(global_config, lc) : global_config)
      end

      def [](name)
        @config[name]
      end

      private

      def load(pattern, solution)
        r = {}
        pattern = detokenize(pattern, SLN_VAR, File.dirname(solution))
        Dir.glob(pattern).each { |f| r = merge(r, YAML.load(File.open(f))) }
        r
      end

      def detokenize(variable, key, value)
        if variable.is_a? Hash
          variable.keys.each { |k| variable[k] = variable[k].gsub(key, value) }
          variable
        elsif variable.is_a? Array
          variable.map { |i| i.gsub(key, value) }
        else
          variable.gsub(key, value)
        end
      end

      def merge(h1, h2)
        return clean(h2) if clean?(h2)
        h1.merge(h2) { |k,o,n| o.is_a?(Hash) ? merge(o, n) : n }
      end

      def clean?(h)
        h.key?(CLEAN_CONFIGURATION_KEY)
      end

      def clean(h)
        h.delete(CLEAN_CONFIGURATION_KEY)
        h
      end
    end

    CLEAN_CONFIGURATION_KEY = 'clean_configuration'
    LC_KEY = 'local_config'
    SLN_VAR = '#{sln}'

    # Get configuration
    def self.[](name, solution = nil)
      @config ||= YAML.load(File.open(GC))
      @lc_key ||= @config.fetch(LC_KEY)
      return @config[name] unless solution
      (@factory ||= {})[solution] ||= Config.new(solution, @config, @lc_key)
      @factory[solution][name]
    end
  end
end
