lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'alpacabuildtool/versioning/versioning'
version = ((AlpacaBuildTool::Versioning.find).to_s '%M.%m.%p.%s').gsub('-', '')

Gem::Specification.new do |s|
  s.name = 'alpacabuildtool'
  s.version = version
  s.author = 'Vasyl Purchel'
  s.email = 'vasyl.purchel@gmail.com'
  s.homepage = 'https://github.com/vasyl-purchel/alpaca'
  s.license = 'MIT'
  s.platform = Gem::Platform::RUBY
  s.summary = 'yet another build tool for Visual Studio solutions'
  s.files = `git ls-files -z`.split("\x0")
  s.test_files = s.files.grep(/^(test|spec|features|test_data)/)
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc', 'alpacabuildtool.rdoc']
  s.rdoc_options << '--title' << 'AlpacaBuildTool'
  s.rdoc_options << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'alpaca'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('cucumber', '~> 2.0.0')
  s.add_development_dependency('rspec', '~> 3.2.0')
  s.add_development_dependency('fakefs')
  s.add_development_dependency('rubocop', '~> 0.30.1')
  s.add_development_dependency('bundler', '~> 1.6')
  s.add_development_dependency('simplecov', '~> 0.7')
  s.add_runtime_dependency('gli', '2.13.0')
  s.add_runtime_dependency('rainbow')
end
