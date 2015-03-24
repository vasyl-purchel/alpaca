require 'alpaca/application'
require 'alpaca/versioning'

# Module *Alpaca* is a namespace provider for current gem
module Alpaca
  LIB_DIR = File.expand_path(File.dirname(__FILE__))
  DEFAULT_SOLUTIONS_PATTERN = ['**/*.sln', '**/Assets']
end
