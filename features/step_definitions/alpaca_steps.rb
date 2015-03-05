require 'rbconfig'
case RbConfig::CONFIG['host_os']
when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
  @prefix = 'bundle exec ruby '
else
  @prefix = ''
end

When(/I get help for "(.*)"/) do |app_name|
  @app_name = app_name
  `#{app_name} help`
end

Then(/the exit status should be (.*)/) do |status|
  expect($CHILD_STATUS.to_i).to eq status.to_i
end
