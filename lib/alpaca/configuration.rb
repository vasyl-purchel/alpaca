require 'yaml'

module Alpaca
  # The *Cofniguration* module provides methods
  # to retrieve from default, global and local configuration scopes
  # and to save configuration into global or local scope
  #  - default configuration (<GEM>/lib/data/.alpaca.conf)
  #  - global configuration (~/.alpaca.conf)
  #  - local configuration (<SOLUTION_FOLDER>/.alpaca.conf)
  class Configuration
    GLOBAL_CONFIGURATION = '~/.alpaca.conf'

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

    # Creates instance of local configuration
    #
    # +solution+:: solution object to find configuration for
    def initialize(solution)
      config_dir = File.dirname(solution.file)
      @file = File.join(config_dir, '.alpaca.conf')
    end

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
  end
end
