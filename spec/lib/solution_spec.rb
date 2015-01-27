require_relative '../../lib/alpaca/solution'

describe Alpaca::Solution do
  before :each do
    @sln = Alpaca::Solution.new '../test_data/TestSolution.sln'
  end

  describe '#new' do
    it 'takes solution file name and returns Solution object' do
      expect(@sln).to be_an_instance_of Alpaca::Solution
    end
  end
end
