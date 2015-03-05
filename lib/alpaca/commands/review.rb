desc 'Describe review here'
arg_name 'Describe arguments to review here'
command :review do |c|
  c.action do
    puts 'review command ran'
  end
end
