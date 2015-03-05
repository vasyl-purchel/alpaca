require 'alpaca/entities/solution'

module Alpaca
  # The *SolutionFactory* class provides method to find
  # solutions to current directory
  class SolutionFactory
    # Yields solutions for given pattern
    #
    # +pattern+:: pattern to search for solution files
    #
    #   SolutionFactory.find '**/*.sln' do |f|
    #     # do some awesome stuff with solution f
    #   end
    #
    #   SolutionFactory.find '**/*.sln', 'nobuild' do |f|
    #     # do some awesome stuff with solution f
    #     # but for solutions that contains nobuild in path+name
    #     # log warn and drop it
    #   end
    def self.find(pattern, exclude = nil)
      Dir.glob(pattern).each do |f|
        if exclude && File.basename(f).include?(exclude)
          Log.warn "NoBuild solution: #{f}"
          next
        end
        yield Alpaca::Solution.new(f) if f.end_with?('.sln')
      end
    end
  end
end
