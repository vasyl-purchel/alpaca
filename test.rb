require 'yaml'

module Alpaca
  class Configuration
    CLEAN_CONFIGURATION_KEY = 'clean_configuration'
    GC = File.expand_path(File.dirname(__FILE__) + '/data/alpaca.yml')

    def initialize
      fail Errors::NoGlobalConfiguration unless File.exist?(GC)
      config = YAML.load(File.open(GC))
    end

    private

    def local_configuration(config)
      lc = config.fetch('local_config')
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
end

def recurcive_merge(h1, h2)
  if h2['clean_configuration']
    h2.delete('clean_configuration')
    return h2
  end
  h1.merge(h2) { |k,o,n| o.is_a?(Hash) ? recurcive_merge(o, n) : n }
end

global_config = File.expand_path(File.dirname(__FILE__) + '/lib/alpaca/data/alpaca.yml')
gc = YAML.load(File.open(global_config))
puts gc.inspect
lc_f = gc.fetch('local_config')
puts "# => #{lc_f}"

local_dir = File.expand_path(File.dirname(__FILE__) + '/lib/alpaca/data/')
files = []
if lc_f.is_a?(Array)
  lc_f.each {|i| files += Dir.glob(File.join(local_dir, i)) }
else
  files += Dir.glob(File.join(local_dir, lc_f))
end
puts files
files.each do |f|
  lc =YAML.load(File.open(f))
  puts "<<<<<<<<<<local>>>>>>>>"
  puts lc.inspect
  gc = recurcive_merge gc, lc
end

puts gc.inspect
