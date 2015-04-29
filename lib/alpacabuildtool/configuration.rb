require 'yaml'
require 'alpacabuildtool/os'

module AlpacaBuildTool
  ##
  # Cofniguration provides methods
  # to retrieve from default, global and local configuration scopes
  # and to save configuration into global or local scope
  #  - default configuration (<GEM>/lib/data/.alpaca.conf)
  #  - global configuration (~/.alpaca.conf)
  #  - local configuration (<SOLUTION_FOLDER>/.alpaca.conf)
  class Configuration
    ##
    # Used to find default configuration
    DATA_DIR = File.join(File.expand_path(File.dirname(__FILE__)), 'data')

    ##
    # Default configuration file with absolute path
    DEFAULT_CONFIGURATION = File.join(DATA_DIR, '.alpaca.conf')

    ##
    # Global configuration file with absolute path
    GLOBAL_CONFIGURATION = File.expand_path('~/.alpaca.conf')

    ##
    # Use to define relative path to local configuration from solution
    LOCAL_CONFIGURATION_PROPERTY = 'local_configuration'

    ##
    # Use in configuration values and in result it will be replaced with
    # solution name
    SOLUTION_NAME_VARIABLE = '#{solution_name}'

    ##
    # Use in configuration values and in result it will be replaced with
    # solution directory path
    SOLUTION_DIR_VARIABLE = '#{solution_directory}'

    ##
    # Use this key to clean configuration entry
    #
    #    #>global configuration:
    #    # MSBuild:
    #    #   options:
    #    #     target:                 ["Clean", "Rebuild"]
    #    #     verbosity:              "minimal"
    #    #     nologo:                 true
    #
    #    #>local configuration:
    #    # MSBuild:
    #    #   options:
    #    #     clean_configuration:    true
    #    #     nologo:                 true
    #
    #    #>results:
    #    # MSBuild:
    #    #   options:
    #    #     nologo:                 true
    CLEAN_CONFIGURATION_KEY = 'clean_configuration'

    ##
    # Saves list of properties into global scope configuration
    #
    # +properties+:: Array of properties 'path.to.property=value'
    def self.set(properties)
      file = File.expand_path GLOBAL_CONFIGURATION
      File.new(file, 'w+').close unless File.exist? file
      config = YAML.load(File.open(file)) || {}
      properties.each { |property| set_property(config, property) }
      File.open(file, 'w+') { |f| f.write config.to_yaml }
    end

    ##
    # Set one property for existing configuration
    #
    # +config+:: hash to hold new property
    # +property+:: property _node1.node2=value_
    #
    #   Configuration.set_propert(hash, 'node1.node2=value')
    #     # will make hash['node1']['node2'] == value
    #     # and create node1 or node2 if they do not exist there
    def self.set_property(config, property)
      name, value = property.split('=')
      nodes = name.split('.')
      tail = nodes.last
      current_node = config
      nodes.each do |node|
        current_node[node] ||= {}
        current_node[node] = value if node == tail
        current_node = current_node[node]
      end
    end

    ##
    # Merges hashes recursively with higher priority
    # for second hash
    # Also second config can contain
    #
    #   clean_configuration: true
    #
    # that will force to take only second configuration content
    # for that configuration level
    #
    # +first_config+:: low priority configuration (hash)
    # +second_config+:: high priority configuration
    def self.merge(first_config, second_config)
      return clean(second_config) if clean?(second_config)
      first_config.merge(second_config) do |_key, old_value, new_value|
        old_value.is_a?(Hash) ? merge(old_value, new_value) : new_value
      end
    end

    ##
    # Removes *clean_configuration* entry for the hash
    #
    # +hash+:: hash to be cleaned
    def self.clean(hash)
      hash.delete CLEAN_CONFIGURATION_KEY
      hash
    end

    ##
    # Check if hash has *clean_configuration* entry
    #
    # +hash+:: hash to be verified
    def self.clean?(hash)
      hash.key? CLEAN_CONFIGURATION_KEY
    end

    ##
    # Creates instance of local configuration
    #
    # +solution+:: solution object to find configuration for
    def initialize(solution)
      local_config = load_local_configuration(solution.dir)
      @configuration = Configuration.merge(global_config, local_config)
      @configuration = detokenize(@configuration, solution)
    end

    ##
    # Saves list of properties into local scope configuration
    #
    # +properties+:: Array of properties 'path.to.property=value'
    def set(properties)
      File.new(@file, 'w+').close unless File.exist? @file
      config = YAML.load(File.open(@file)) || {}
      properties.each do |property|
        Configuration.set_property(config, property)
      end
      File.open(@file, 'w+') { |f| f.write config.to_yaml }
    end

    ##
    # Returns hash with configuration for entry
    #
    # +entry+:: entry name
    def [](entry)
      @configuration[entry]
    end

    private

    def global_config
      if Configuration.class_variable_defined? '@@global_configuration'
        return Marshal.load(Marshal.dump(@@global_configuration))
      end
      @@global_configuration = load_global_configuration
    end

    def load_global_configuration
      default_config = YAML.load(File.open(DEFAULT_CONFIGURATION)) || {}
      if File.exist?(GLOBAL_CONFIGURATION)
        global_conf = YAML.load(File.open(GLOBAL_CONFIGURATION)) || {}
        Configuration.merge(default_config, global_conf)
      else
        default_config
      end
    end

    def load_local_configuration(solution_dir)
      config_path = global_config[LOCAL_CONFIGURATION_PROPERTY]
      @file = File.expand_path(File.join(solution_dir, config_path))
      return {} unless File.exist? @file
      YAML.load(File.open(@file)) || {}
    end

    def detokenize(config, solution)
      config = detokenize_os(config) if config.is_a? Hash
      return detokenize_string(config, solution) if config.is_a? String
      return config.map { |i| detokenize(i, solution) } if config.is_a? Array
      return detokenize_hash(config, solution) if config.is_a? Hash
      config
    end

    def detokenize_os(value)
      (value.is_a?(Hash) && value[Os.os]) ? value[Os.os] : value
    end

    def detokenize_string(value, solution)
      value = value.gsub(SOLUTION_DIR_VARIABLE, solution.dir)
      value.gsub(SOLUTION_NAME_VARIABLE, File.basename(solution.file, '.*'))
    end

    def detokenize_hash(value, solution)
      value.keys.each { |key| value[key] = detokenize(value[key], solution) }
      value
    end
  end
end
