require 'spec_helper'

describe Alpaca::Solution do
  describe '#new' do
    context 'When only solution file passed as argument' do
      before :all do
        @sln_file = 'spec/test_data/TestSolution.sln'
        @build_tool = 'C:/Program Files (x86)/MSBuild/12.0/Bin/MSBuild.exe'
        @sln = Alpaca::Solution.new @sln_file
      end

      it 'returns Solution object' do
        expect(@sln).to be_an_instance_of Alpaca::Solution
      end

      it 'returns solution file inside' do
        expect(@sln.file).to eq @sln_file
      end

      it 'returns MSBuild for .net 4.5 as build_tool' do
        expect(@sln.build_tool).to be_an_instance_of Alpaca::MSBuild
        expect(@sln.build_tool.to_s).to eq @build_tool
      end
    end

    context 'When solution file and .net version passed as arguments' do
      before :all do
        @version = :net40
        @path_version = 'v4.0.30319'

        @sln_file = 'spec/test_data/TestSolution.sln'
        @old_path = 'C:/WINDOWS/Microsoft.NET/Framework/'
        @build_tool = @old_path + @path_version + '/MSBuild.exe'
        @sln = Alpaca::Solution.new @sln_file, @version
      end

      it 'returns Solution object' do
        expect(@sln).to be_an_instance_of Alpaca::Solution
      end

      it 'returns solution file inside' do
        expect(@sln.file).to eq @sln_file
      end

      it "returns MSBuild for .net #{@version} as build_tool" do
        expect(@sln.build_tool).to be_an_instance_of Alpaca::MSBuild
        expect(@sln.build_tool.to_s).to eq @build_tool
      end
    end
  end

  describe '#compile' do
    context 'without any parameters' do
      it 'builds solution in Release mode' do
        @sln = Alpaca::Solution.new 'spec/test_data/TestSolution.sln'
        expect(@sln.build_tool).to receive(:system).with(
          'C:/Program Files (x86)/MSBuild/12.0/Bin/MSBuild.exe',
          'spec/test_data/TestSolution.sln',
          '/verbosity:minimal',
          '/target:Clean;Rebuild',
          '/property:Configuration=Release')
        @sln.compile
      end
    end
  end
end
