desc 'Describe push here'
arg_name 'Describe arguments to push here'
command :push do |c|
  c.action do
    puts 'push command ran'
  end
end
