# desc 'Read-Eval-Print-Loop'
# command :repl do |c|
# TODO: repl not works if you have multi-line input
# c.action do
# %w(readline rubygems bond).each { |e| require e }
# Bond.start
# history_file = File.join(ENV['HOME'], '.mini_irb_history')
# if File.exist?(history_file)
# IO.readlines(history_file).each { |e| Readline::HISTORY << e.chomp }
# end
# while (input = Readline.readline('>> ', true)) != 'exit'
# begin
# puts "=> #{eval(input).inspect}"
# rescue Exception
# puts "Error: #{$ERROR_INFO}"
# end
# end
# File.open(history_file, 'w') do |f|
# f.write Readline::HISTORY.to_a.join("\n")
# end
# end
# end
