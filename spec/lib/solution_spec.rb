require_relative '../../lib/alpaca/solution'

describe Alpaca::Solution do
  before :each do
    allow(subject).to receive(:puts)
  end
  let(:sln) do
    {
      file: 'spec/test_data/TestSolution.sln',
      file_path: File.expand_path('spec/test_data/TestSolution.sln'),
      format_version: '12.00',
      vs_version: '12.0.30723.0',
      min_vs_version: '10.0.40219.1',
      project: {
        id: '{B9BAB17F-FD42-452B-8DE3-A85254043711}',
        name: 'TestSolution',
        file: 'TestSolution\TestSolution.csproj'
      }
    }
  end

  describe '::new' do
    context 'When only solution file passed as argument' do
      subject { Alpaca::Solution.new sln[:file] }

      it 'returns Solution object' do
        expect(subject).to be_an_instance_of Alpaca::Solution
      end

      it 'returns object with solution file' do
        expect(subject.file).to eq sln[:file_path]
      end

      it 'returns object with .Net Framework 4.5.1' do
        expect(subject.net_version).to eq :net451
      end

      it 'returns object with project from solution' do
        expect(subject.projects).to eq [sln[:project]]
      end

      it 'returns object with solution format version' do
        expect(subject.format_version).to eq sln[:format_version]
      end

      it 'returns object with visual studio version' do
        expect(subject.visual_studio_version).to eq sln[:vs_version]
      end

      it 'returns object with minimum visual studio version' do
        expect(subject.minimum_visual_studio_version)
          .to eq sln[:min_vs_version]
      end
    end

    context 'When solution file and .net version passed as arguments' do
      let(:net_version) { :net40 }
      subject { Alpaca::Solution.new sln[:file], net_version }

      it 'returns Solution object' do
        expect(subject).to be_an_instance_of Alpaca::Solution
      end

      it 'returns object with solution file' do
        expect(subject.file).to eq sln[:file_path]
      end

      it 'returns object with .Net Framework 4.0' do
        expect(subject.net_version).to eq :net40
      end

      it 'returns object with project from solution' do
        expect(subject.projects).to eq [sln[:project]]
      end

      it 'returns object with solution format version' do
        expect(subject.format_version).to eq sln[:format_version]
      end

      it 'returns object with visual studio version' do
        expect(subject.visual_studio_version).to eq sln[:vs_version]
      end

      it 'returns object with minimum visual studio version' do
        expect(subject.minimum_visual_studio_version)
          .to eq sln[:min_vs_version]
      end
    end

    context 'When solution file does not exists' do
      subject { Alpaca::Solution }

      it 'then fails with RuntimeError' do
        expect { Alpaca::Solution.new 'ghost.sln' }.to raise_error
      end
    end
  end

  describe '#compile' do
    let(:tool) { 'C:/Program Files (x86)/MSBuild/12.0/Bin/MSBuild.exe' }
    subject { Alpaca::Solution.new sln[:file], :net45 }
    before :each do
      allow(Alpaca::MSBuild)
        .to receive(:executable)
        .with(:net45)
        .and_return(tool)
    end

    context 'without any parameters' do
      it 'rebuilds solution with default configuration' do
        result = [tool, sln[:file_path]].join(' ')
        expect(subject).to receive(:`).with(result)
        subject.compile
      end
    end

    context 'with Debug mode as a parameter' do
      let(:result) do
        a = [tool, sln[:file_path]]
        a += %w(/Property:Configuration=Debug)
        a.join(' ')
      end
      it 'rebuilds solution in debug mode' do
        expect(subject).to receive(:`).with(result)
        subject.compile 'Debug'
      end
    end

    context 'with block' do
      let(:result) do
        a = [tool, sln[:file_path]]
        a += %w(/NoLogo /Target:Build)
        a.join(' ')
      end
      it 'builds solution with specific parameters' do
        expect(subject).to receive(:`).with(result)
        subject.compile do
          configure(no_logo: true, target: %w(Build))
        end
      end
    end

    context 'with block and Debug mode as a parameter' do
      let(:result) do
        a = [tool, sln[:file_path]]
        a += %w(/NoLogo /Target:Build /Property:Configuration=Debug)
        a.join(' ')
      end
      it 'builds solution with specific parameters and in Debug mode' do
        expect(subject).to receive(:`).with(result)
        subject.compile('Debug') do
          configure(no_logo: true, target: %w(Build))
        end
      end
    end

    context 'with block and conflicting Debug mode as a parameter' do
      let(:result) do
        a = [tool, sln[:file_path]]
        a += %w(/NoLogo /Target:Build /Property:Configuration=Debug)
        a.join(' ')
      end
      it 'builds solution with specific parameters and in Debug mode' do
        expect(subject).to receive(:`).with(result)
        subject.compile('Debug') do
          configure(no_logo: true, target: %w(Build))
          configure(property: { 'Configuration' => 'Release' })
        end
      end
    end
  end
end
