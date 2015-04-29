When(/^I run "(.*?)"$/) do |command_line|
  call = "#{prefix}#{command_line}"
  @call_result = `#{call}`
end

When(/I get help for "(.*)"/) do |app_name|
  @app_name = app_name
  step %(I run "#{@app_name} help")
end

Then(/the exit status should be (.*)/) do |status|
  expect($CHILD_STATUS.to_i).to eq status.to_i
end
