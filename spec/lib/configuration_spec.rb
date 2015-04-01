require 'spec_helper'
require 'fakefs/spec_helpers'
require 'ostruct'

describe Alpaca::Configuration do
  include FakeFS::SpecHelpers

  describe '.set' do
    let(:file) { File.expand_path '~/.alpaca.conf' }

    context 'when global configuration file does not exist' do
      before(:each) { FileUtils.mkdir_p(File.dirname(file)) }
      let(:properties) { ['hello.world=hi'] }
      let(:expected_content) { "---\nhello:\n  world: hi\n" }

      it 'then it creates "~/.alpaca.config" file' do
        Alpaca::Configuration.set properties
        expect(File.exist? file).to be true
      end

      it 'and it saves property to file' do
        Alpaca::Configuration.set properties
        expect(File.read file).to eq expected_content
      end
    end

    context 'when global configuration file exist' do
      let(:content) { "---\nhello:\n  world: hi\n" }
      before(:each) do
        FileUtils.mkdir_p(File.dirname(file))
        File.open(file, 'w+') { |f| f.write content }
      end

      context 'and requested property update' do
        let(:properties) { ['hello.world=update'] }
        let(:updated_content) { "---\nhello:\n  world: update\n" }
        it 'then it updates property' do
          Alpaca::Configuration.set properties
          expect(File.read file).to eq updated_content
        end
      end

      context 'and adding new property' do
        let(:properties) { ['hello.my_world=kitty'] }
        let(:expected_content) { content + "  my_world: kitty\n" }
        it 'then it saves property to file' do
          Alpaca::Configuration.set properties
          expect(File.read file).to eq expected_content
        end
      end
    end
  end

  describe '#set' do
    let(:file_path) do
      require 'rbconfig'
      case RbConfig::CONFIG['host_os']
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
        'd:\solution'
      else
        '/home/solution'
      end
    end
    let(:file) { File.join file_path, '.alpaca.conf' }
    let(:solution) do
      solution = OpenStruct.new
      solution.file = File.join(file_path, 'some.sln')
      solution.dir = file_path
      solution
    end
    subject do
      data_dir = Alpaca::Configuration.const_get(:DATA_DIR)
      default_config = File.join(data_dir, '.alpaca.conf')
      FileUtils.mkdir_p File.dirname(default_config)
      File.open(default_config, 'w+') do |f|
        f.write "---\nlocal_configuration: '.alpaca.conf'"
      end
      c = Alpaca::Configuration.new solution
      c.set properties
    end

    context 'when local configuration file does not exist' do
      before(:each) { FileUtils.mkdir_p(File.dirname(file)) }
      let(:properties) { ['hello.world=hi'] }
      let(:expected_content) { "---\nhello:\n  world: hi\n" }

      it 'then it creates "solution_directory\.alpaca.conf" file' do
        subject
        expect(File.exist? file).to be true
      end

      it 'and it saves property to file' do
        subject
        expect(File.read file).to eq expected_content
      end
    end

    context 'when local configuration file exist' do
      let(:content) { "---\nhello:\n  world: hi\n" }
      before(:each) do
        FileUtils.mkdir_p(File.dirname(file))
        File.open(file, 'w+') { |f| f.write content }
      end

      context 'and requested property update' do
        let(:properties) { ['hello.world=update'] }
        let(:updated_content) { "---\nhello:\n  world: update\n" }
        it 'then it updates property' do
          subject
          expect(File.read file).to eq updated_content
        end
      end

      context 'and adding new property' do
        let(:properties) { ['hello.my_world=kitty'] }
        let(:expected_content) { content + "  my_world: kitty\n" }
        it 'then it saves property to file' do
          subject
          expect(File.read file).to eq expected_content
        end
      end
    end
  end

  describe '.new' do
    context 'when global configuration exist' do
      context 'and local configuration overrides it' do
        let(:default_config) do
          data_dir = Alpaca::Configuration.const_get(:DATA_DIR)
          File.join(data_dir, '.alpaca.conf')
        end
        let(:global_config) { File.expand_path '~/.alpaca.conf' }
        let(:global_content) do
          "---\nlocal_configuration: '.alpaca.conf'\n"\
            "Tool:\n  property: old_value\n  target: "\
            "'\#{solution_name}.new'\n  property2:\n    "\
            ":windows: '\#{solution_directory}'\n    "\
            ":linux: '/usr/alpaca'"
        end
        let(:solution_dir) do
          require 'rbconfig'
          case RbConfig::CONFIG['host_os']
          when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
            'd:\solution'
          else
            '/home/solution'
          end
        end
        let(:local_config) { File.expand_path "#{solution_dir}/.alpaca.conf" }
        let(:local_content) { "---\nTool:\n  property: new_value" }
        let(:solution) do
          solution = OpenStruct.new
          solution.file = File.join solution_dir, 'alpaca.sln'
          solution.dir = solution_dir
          solution
        end
        subject { Alpaca::Configuration.new solution }

        def create_config(file, content)
          FileUtils.mkdir_p(File.dirname(file))
          File.open(file, 'w+') { |f| f.write content }
        end

        before(:each) do
          create_config default_config, "---\n"
          create_config global_config, global_content
          create_config local_config, local_content
          gc_var = :@@global_configuration
          if Alpaca::Configuration.class_variable_defined? gc_var
            Alpaca::Configuration.remove_class_variable gc_var
          end
          allow(Alpaca::Os).to receive(:os).and_return(:windows)
        end

        it 'merges global with local with higher priority to local' do
          value = subject.instance_variable_get(:@configuration)
          expect(value['local_configuration']).to eq '.alpaca.conf'
          expect(value['Tool']['property']).to eq 'new_value'
          expect(value['Tool']['target']).to_not be nil
          expect(value['Tool']['property2']).to_not be nil
        end

        it 'detokenize OS from configuration' do
          value = subject.instance_variable_get(:@configuration)
          expect(value['Tool']['property2']).to_not eq 'usr/alpaca'
        end

        it 'detokenize solution variable #{solution_name}' do
          value = subject.instance_variable_get(:@configuration)
          expect(value['Tool']['target']).to eq 'alpaca.new'
        end

        it 'detokenize solution variable #{solution_directory}' do
          value = subject.instance_variable_get(:@configuration)
          expect(value['Tool']['property2']).to eq solution.dir
        end
      end
    end
  end
end
