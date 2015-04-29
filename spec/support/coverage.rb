if ENV['TRAVIS'] || ENV['COVERAGE']
  require 'simplecov'

  if ENV['TRAVIS']
    require 'coveralls'
    SimpleCov.formatter = Coveralls::SimpleCov::Formatter
  end

  SimpleCov.start do
    add_filter '/spec/'

    add_group 'entities', 'lib/alpacabuildtool/entities'
    add_group 'log', 'lib/alpacabuildtool/log'
    add_group 'managers', 'lib/alpacabuildtool/managers'
    add_group 'tools', 'lib/alpacabuildtool/tools'
    add_group 'package_types', 'lib/alpacabuildtool/package_types'
    add_group 'versioning', 'lib/alpacabuildtool/versioning'
    add_group 'lib', 'lib/alpacabuildtool'
  end
end

if ENV['DEV']
  Dir.glob('lib/**/*.rb').each do |file|
    require file.gsub('lib/', '').gsub('.rb', '')
  end
end
