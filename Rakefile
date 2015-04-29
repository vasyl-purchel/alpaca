require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/clean'
require 'rbconfig'
require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'
require 'cucumber'
require 'cucumber/rake/task'
require 'benchmark'
require 'rainbow'
require 'rainbow/ext/string' unless String.method_defined?(:color)

module Rake
  # Redefining rake task to show benchmarking
  class Task
    def execute_with_benchmark(*args)
      bench = Benchmark.measure do
        execute_without_benchmark(*args)
      end
      puts '###########################################################'
      puts "#{name} --> #{bench}"
      puts '###########################################################'
    end
    alias_method :execute_without_benchmark, :execute
    alias_method :execute, :execute_with_benchmark
  end
end

Rake::RDocTask.new do |rd|
  rd.main = 'README.rdoc'
  rd.rdoc_files.include('README.rdoc', 'lib/**/*.rb', 'bin/**/*')
  rd.title = 'AlpacaBuildTool'
end

Bundler.setup
Bundler::GemHelper.install_tasks

CUKE_RESULTS = 'results.html'
CLEAN << CUKE_RESULTS
desc 'Run features'
Cucumber::Rake::Task.new(:features) do |t|
  opts = "features --format html -o #{CUKE_RESULTS} --format pretty -x"
  opts += " --tags #{ENV['TAGS']}" if ENV['TAGS']
  case RbConfig::CONFIG['host_os']
  when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
    opts += ' --tags @windows'
  else
    opts += ' --tags @linux'
  end
  t.cucumber_opts =  opts
  t.fork = false
end

task cucumber: :features

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:test) do |task|
  task.rspec_opts = '--color --format documentation'
end

desc 'Run RSpec with code coverage'
task :coverage do
  ENV['COVERAGE'] = 'true'
  Rake::Task['test'].execute
end

require 'rubocop/rake_task'
RuboCop::RakeTask.new(:rubocop) do |task|
  task.formatters = %w(simple html)
  task.options << '-ooffences.html'
end

task default: [:rubocop, :test, :features]
