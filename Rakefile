require 'bundler/setup'
require 'bundler/gem_tasks'
require 'rake/clean'
require 'rubygems'
require 'rubygems/package_task'
require 'rdoc/task'
require 'cucumber'
require 'cucumber/rake/task'
Rake::RDocTask.new do |rd|
  rd.main = 'README.rdoc'
  rd.rdoc_files.include('README.rdoc', 'lib/**/*.rb', 'bin/**/*')
  rd.title = 'Alpaca'
end

Bundler.setup
Bundler::GemHelper.install_tasks

CUKE_RESULTS = 'results.html'
CLEAN << CUKE_RESULTS
desc 'Run features'
Cucumber::Rake::Task.new(:features) do |t|
  opts = "features --format html -o #{CUKE_RESULTS} --format pretty -x"
  opts += " --tags #{ENV['TAGS']}" if ENV['TAGS']
  t.cucumber_opts =  opts
  t.fork = false
end

desc 'Run features tagged as work-in-progress (@wip)'
Cucumber::Rake::Task.new('features:wip') do |t|
  tag_opts = '--tags @wip'
  format_opts = '--format pretty'
  output_opts = "--format html -o #{CUKE_RESULTS}"
  t.cucumber_opts = "features #{output_opts} #{format_opts} -x -s #{tag_opts}"
  t.fork = false
end

task cucumber: :features
task 'cucumber:wip' => 'features:wip'
task wip: 'features:wip'

require 'rspec/core/rake_task'
RSpec::Core::RakeTask.new(:test)

require 'rubocop/rake_task'
RuboCop::RakeTask.new

task default: [:rubocop, :test, :features]
