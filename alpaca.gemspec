require File.join([File.dirname(__FILE__), 'lib', 'alpaca', 'version.rb'])
Gem::Specification.new do |s|
  s.name = 'alpaca'
  s.version = Alpaca::VERSION
  s.author = 'Vasyl Purchel'
  s.email = 'vasyl.purchel@gmail.com'
  s.homepage = 'https://github.com/vasyl-purchel/alpaca'
  s.license = 'MIT'
  s.platform = Gem::Platform::RUBY
  s.summary = 'just learning ruby'
  s.files = `git ls-files -z`.split("\x0")
  s.test_files = s.files.grep(/^(test|spec|features)/)
  s.require_paths << 'lib'
  s.has_rdoc = true
  s.extra_rdoc_files = ['README.rdoc', 'alpaca.rdoc']
  s.rdoc_options << '--title' << 'alpaca' << '--main' << 'README.rdoc' << '-ri'
  s.bindir = 'bin'
  s.executables << 'alpaca'
  s.add_development_dependency('rake')
  s.add_development_dependency('rdoc')
  s.add_development_dependency('aruba')
  s.add_development_dependency('rspec')
  s.add_development_dependency('rubocop')
  s.add_development_dependency('bundler', '~> 1.6')
  s.add_runtime_dependency('gli', '2.12.2')
  s.add_runtime_dependency('rainbow')
end
