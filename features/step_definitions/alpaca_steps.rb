When /^I get help for "([^"]*)"$/ do |app_name|
  @app_name = app_name
  step %(I run `bundle exec ruby ../../bin/#{app_name} help`)
end

# Add more step definitions here
