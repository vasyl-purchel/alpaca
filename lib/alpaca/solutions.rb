require 'alpaca/entities/solution'

module Alpaca
  # The *Solutions* module provides method to find
  # solutions to current directory
  module Solutions
    # Yields solutions for given pattern
    #
    # +pattern+:: pattern to search for solution files
    #
    #   Solutions.each '**/*.sln' do |f|
    #     # do some awesome stuff with solution f
    #   end
    def self.each(pattern)
      Dir.glob(pattern).each do |f|
        yield Alpaca::Solution.new(f) if f.end_with?('.sln')
      end
    end
  end
end
