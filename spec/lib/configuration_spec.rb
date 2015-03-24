require 'alpaca/configuration'
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
      solution
    end
    subject do
      c = Alpaca::Configuration.new solution
      c.set properties
    end

    context 'when local configuration file does not exist' do
      before(:each) { FileUtils.mkdir_p(File.dirname(file)) }
      let(:properties) { ['hello.world=hi'] }
      let(:expected_content) { "---\nhello:\n  world: hi\n" }

      it 'then it creates "d:\solution\.alpaca.conf" file' do
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
        let(:global_config) { File.expand_path '~/.alpaca.conf' }
        let(:global_content) do
          <<EOF
---
local_config: "#{SOLUTION_FOLDER}/.alpaca.conf"
Tool:
  property: old_value
  target: "#{SOLUTION_NAME}"
EOF
        end
        let(:local_config) { File.expand_path 'c:\alpaca\.alpaca.conf' }
        let(:solution) do
          solution = OpenStruct.new
          solution.file = 'c:\alpaca\alpaca.sln'
          solution
        end
        before(:each) do
          FileUtils.mkdir_p(File.dirname(file))
          File.open(file, 'w+') { |f| f.write content }
        end

        it 'merges global with local with higher priority to local'
        it 'detokenize OS from configuration'
        it 'detokenize solution variable SOLUTION_NAME'
        it 'detokenize solution variable SOLUTION_FOLDER'
      end
    end
  end
end
