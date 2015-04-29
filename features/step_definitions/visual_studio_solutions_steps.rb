Then(/^alpaca build file (.*?)$/) do |project_file|
  proj = File.basename(project_file, '.*')
  build_project = /#{proj} -> (.*?)\\#{project_file}/
  expect(@call_result.match(build_project)).to_not be nil
end

Then(/^alpaca do not build file (.*?)$/) do |project_file|
  proj = File.basename(project_file, '.*')
  build_project = /#{proj} -> (.*?)\\#{project_file}/
  expect(@call_result.match(build_project)).to be nil
end

Then(/^alpaca restore nuget packages for (.*?)$/) do |solution_file|
  solution_dir = File.dirname(File.expand_path(solution_file))
  nuget_call = /Nuget.exe restore #{File.expand_path(solution_file)}/
  expect(@call_result.match(nuget_call)).to_not be nil
  expect(Dir.glob(solution_dir + '/packages/*').count).to be > 0
end

Then(/^solution has failing unit test$/) do
  # nothing to do here as there is failing unit test in solution 2
  # step is used only as a marker in reports
end

Then(/^alpaca generate unit test results (.*?)$/) do |results_file|
  expect(File.exist?(results_file)).to be true
end

Then(/^alpaca generate test coverage summary (.*?)$/) do |summary_file|
  expect(File.exist?(summary_file)).to be true
end

Then(/^alpaca generate unit tests report (.*?)$/) do |report_file|
  expect(File.exist?(report_file)).to be true
end

Then(/^alpaca generate coverage report (.*?)$/) do |index_file|
  expect(File.exist?(index_file)).to be true
end

Then(/^alpaca creates (.*?)$/) do |package_file|
  expect(File.exist?(package_file)).to be true
end

AfterStep('@teardown_changes') do
  `git stash save --keep-index --include-untracked`
end
