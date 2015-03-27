Then(/^alpaca update AssemblyInfo files for (.*?)$/) do |solution_file|
  solution_dir = File.dirname File.expand_path(solution_file)
  git_changes = `git diff --name-only #{solution_dir}`.split("\n")
  expect(git_changes.length).to be >= 1
  git_changes.each do |change|
    expect(change.include? 'AssemblyInfo').to eq true
  end
end

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
  nuget_call = /Nuget.exe  restore  #{File.expand_path(solution_file)}/
  expect(@call_result.match(nuget_call)).to_not be nil
  expect(Dir.glob(solution_dir + '/packages/*').count).to be > 0
end

Then(/^alpaca run tests for (.*?)$/) do |solution_file|
  pending "check that tests were runned for #{solution_file}"
end

Then(/^alpaca generate unit test results (.*?)$/) do |results_file|
  pending "check that #{results_file} was generated"
end

Then(/^alpaca generate test coverage summary for (.*?)$/) do |summary_file|
  pending "check that #{summary_file} was generated"
end

Then(/^alpaca generate coverage report (.*?)$/) do |index_file|
  pending "check that #{index_file} was generated"
end

Then(/^alpaca creates (.*?)$/) do |package|
  pending "check that #{package} was created"
end

Then(/^alpaca commit (.*?) file to git$/) do |semver_file|
  pending "check that #{semver_file} was committed"
end

Then(/^alpaca download latest package (.*?)$/) do |package|
  pending "check that #{package} was downloaded"
end

Then(/^alpaca repack it as (.*?)$/) do |package|
  pending "check that it was repacked as #{package}"
end

Then(/^alpaca change inner (.*?) version to ([\d\.]+)$/) do |file, version|
  pending "check that #{file} in generated package contains #{version} version"
end

Then(/^alpaca push package (.*?)$/) do |package|
  pending "check that #{package} was pushed"
end
