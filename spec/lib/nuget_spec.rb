require_relative '../../lib/alpaca/nuget'
require_relative 'spec_helper'

RSpec.configure do |c|
  c.include Helpers
end

describe Alpaca::Nuget do
  before :each do
    allow(subject).to receive(:puts)
  end
  describe '#new' do
    context 'When only exe path passed as argument' do
      subject { Alpaca::Nuget.new 'path/nuget.exe' }
      it 'returns Nuget object' do
        expect(subject).to be_an_instance_of Alpaca::Nuget
      end

      it 'returns object with exe path stored' do
        expect(subject.exe).to eq 'path/nuget.exe'
      end

      it 'returns object without config' do
        expect(subject.config).to be_nil
      end
    end

    context 'When exe path and config path are passed as arguments' do
      subject { Alpaca::Nuget.new 'path/nuget.exe', 'path/nuget.config' }
      it 'returns Nuget object' do
        expect(subject).to be_an_instance_of Alpaca::Nuget
      end

      it 'returns object with exe path stored' do
        expect(subject.exe).to eq 'path/nuget.exe'
      end

      it 'returns object with config path stored' do
        expect(subject.config).to eq 'path/nuget.config'
      end
    end
  end

  describe '#install' do
    context 'When package is passed' do
      subject { Alpaca::Nuget.new 'n.exe', 'init.config' }
      let(:result) do
        'n.exe install packageId -ConfigFile init.config'
      end
      it 'execute `nuget install` with with -ConfigFile from initialization' do
        expect(subject).to receive(:`).with(result)
        subject.install 'packageId'
      end
    end

    context 'When package is passed and config file configured in block' do
      subject { Alpaca::Nuget.new 'n.exe', 'init.config' }
      let(:result) { 'n.exe install packageId -ConfigFile block.config' }
      it 'execute `nuget install` with -ConfigFile from block' do
        expect(subject).to receive(:`).with(result)
        subject.install 'packageId' do
          configure(config_file: 'block.config')
        end
      end
    end
  end

  describe '#restore' do
    context 'When solution is passed' do
      subject { Alpaca::Nuget.new 'n.exe', 'init.config' }
      let(:result) { 'n.exe restore some.sln -ConfigFile init.config' }
      it 'execute `nuget restore` with with -ConfigFile from initialization' do
        expect(subject).to receive(:`).with(result)
        subject.restore 'some.sln'
      end
    end

    context 'When solution is passed and config file configured in block' do
      subject { Alpaca::Nuget.new 'n.exe', 'init.config' }
      let(:result) { 'n.exe restore some.sln -ConfigFile block.config' }
      it 'execute `nuget restore` with -ConfigFile from block' do
        expect(subject).to receive(:`).with(result)
        subject.restore 'some.sln' do
          configure(config_file: 'block.config')
        end
      end
    end
  end

  describe '#pack' do
    context 'When nuspec is passed' do
      subject { Alpaca::Nuget.new 'n.exe', 'init.config' }
      let(:result) { 'n.exe pack some.nuspec -ConfigFile init.config' }
      it 'execute `nuget pack` with with -ConfigFile from initialization' do
        expect(subject).to receive(:`).with(result)
        subject.pack 'some.nuspec'
      end
    end

    context 'When nuspec is passed and config file configured in block' do
      subject { Alpaca::Nuget.new 'n.exe', 'init.config' }
      let(:result) { 'n.exe pack some.nuspec -ConfigFile block.config' }
      it 'execute `nuget pack` with -ConfigFile from block' do
        expect(subject).to receive(:`).with(result)
        subject.pack 'some.nuspec' do
          configure(config_file: 'block.config')
        end
      end
    end
  end

  describe '#push' do
    context 'When package is passed' do
      subject { Alpaca::Nuget.new 'n.exe', 'init.config' }
      let(:result) { 'n.exe push some.nupkg -ConfigFile init.config' }
      it 'execute `nuget push` with with -ConfigFile from initialization' do
        expect(subject).to receive(:`).with(result)
        subject.push 'some.nupkg'
      end
    end

    context 'When package is passed and config file configured in block' do
      subject { Alpaca::Nuget.new 'n.exe', 'init.config' }
      let(:result) { 'n.exe push some.nupkg -ConfigFile block.config' }
      it 'execute `nuget push` with -ConfigFile from block' do
        expect(subject).to receive(:`).with(result)
        subject.push 'some.nupkg' do
          configure(config_file: 'block.config')
        end
      end
    end
  end

  describe '#promote' do
    context 'When package is passed' do
      subject { Alpaca::Nuget.new 'n.exe', 'init.config' }
      it 'promote the package' do
      end
    end
  end
end
