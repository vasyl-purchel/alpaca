require 'alpaca/tools/nuget'

describe Alpaca::Nuget do
  before :each do
    allow(subject).to receive(:puts)
  end
  describe '::new' do
    context 'When only exe path passed as argument' do
      subject { Alpaca::Nuget.new 'path/nuget.exe' }
      it 'returns Nuget object' do
        expect(subject).to be_an_instance_of Alpaca::Nuget
      end

      it 'returns object with exe path stored' do
        expect(subject.instance_variable_get :@exe).to eq 'path/nuget.exe'
      end

      it 'returns object without config' do
        expect(subject.instance_variable_get :@config).to be_nil
      end
    end

    context 'When exe path and config path are passed as arguments' do
      subject { Alpaca::Nuget.new 'path/nuget.exe', 'path/nuget.config' }
      it 'returns Nuget object' do
        expect(subject).to be_an_instance_of Alpaca::Nuget
      end

      it 'returns object with exe path stored' do
        expect(subject.instance_variable_get :@exe).to eq 'path/nuget.exe'
      end

      it 'returns object with config path stored' do
        expect(subject.instance_variable_get :@config)
          .to eq 'path/nuget.config'
      end
    end
  end

  describe '#run' do
    context 'When package is passed' do
      subject { Alpaca::Nuget.new 'n.exe', 'init.config' }
      let(:result) do
        'n.exe install packageId -ConfigFile init.config'
      end
      it 'execute `nuget install` with with -ConfigFile from initialization' do
        expect(subject).to receive(:`).with(result)
        subject.run 'install', 'packageId'
      end
    end

    context 'When package is passed and config file configured in block' do
      subject { Alpaca::Nuget.new 'n.exe', 'init.config' }
      let(:result) { 'n.exe install packageId -ConfigFile block.config' }
      it 'execute `nuget install` with -ConfigFile from block' do
        expect(subject).to receive(:`).with(result)
        subject.run 'install', 'packageId' do
          configure(config_file: 'block.config')
        end
      end
    end
  end

  describe '#promote' do
    context 'When package is passed' do
      subject { Alpaca::Nuget.new 'n.exe', 'init.config' }
      it 'promote the package'
    end
  end
end
