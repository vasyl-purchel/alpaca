require 'alpaca/errors'
require 'alpaca/logger'
require 'alpaca/os'
require 'alpaca/versioning'
require 'alpaca/entities/config'
require 'alpaca/entities/font'
require 'alpaca/entities/solution'
require 'alpaca/entities/version'
require 'alpaca/configuration'
require 'alpaca/solutions'
require 'alpaca/tools/base_formatter'
require 'alpaca/tools/camel_names_formatter'
require 'alpaca/tools/console_application'
require 'alpaca/tools/console_command_suit'
require 'alpaca/tools/console_tool'
require 'alpaca/tools/console_tool_wrapper'
require 'alpaca/tools/git'
require 'alpaca/tools/msbuild'
require 'alpaca/tools/msbuild_formatter'
require 'alpaca/tools/nuget'
require 'alpaca/tools/nunit'
require 'alpaca/tools/open_cover'
require 'alpaca/tools/ssh'
require 'alpaca/tools/gerrit'

# Module *Alpaca* is a namespace provider for current gem
module Alpaca
  LIB_DIR = File.expand_path(File.dirname(__FILE__))
end
