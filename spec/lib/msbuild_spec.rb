require 'fakefs/spec_helpers'
require 'alpaca/tools/msbuild'
require_relative 'spec_helper'

# The *TestCases* module provides test_cases
# as a placeholder for long strings like for MSBuild.exe
# and it can be included in RSpec configuration so
# tests can use it
module TestCases
  def test_cases
    @test_cases = {
      x86_net45: 'C:\Program Files\MSBuild\12.0\Bin\MSBuild.exe',
      x86_net451: 'C:\Program Files\MSBuild\12.0\Bin\MSBuild.exe',
      x64_net45: 'C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe',
      x64_net451: 'C:\Program Files (x86)\MSBuild\12.0\Bin\MSBuild.exe',
      net4: 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe',
      net40: 'C:\Windows\Microsoft.NET\Framework\v4.0.30319\MSBuild.exe'
    }
  end
end

RSpec.configure do |c|
  c.include TestCases
  c.include Helpers
end

describe Alpaca::MSBuild do
  include FakeFS::SpecHelpers
  describe '::new' do
    def testcase(key)
      normalize_path(test_cases[key])
    end

    def local(net_framework, key)
      t = Alpaca::MSBuild.new if net_framework.nil?
      t = Alpaca::MSBuild.new(net_framework) unless net_framework.nil?
      t.instance_variable_get(key).downcase
    end

    context 'when used on windows system' do
      before :each do
        mock_os(:windows)
      end

      context 'and new .net framework needed' do
        context 'and x86 version of windows is used' do
          let(:dir) { 'C:\Program Files\MSBuild\12.0\Bin' }
          let(:file) { 'MSBuild.exe' }
          before :each do
            mock_env('ProgramFiles(x86)', nil)
            FileUtils.mkdir_p(dir)
            File.new(File.join(dir, file), 'w')
          end

          it 'then returns new msbuild from program files by default' do
            expect(local(nil, :@exe)).to eq(testcase(:x86_net451))
          end

          it 'then returns new msbuild from program files for :net451' do
            expect(local(:net451, :@exe)).to eq(testcase(:x86_net451))
          end

          it 'then returns new msbuild from program files for :net45' do
            expect(local(:net45, :@exe)).to eq(testcase(:x86_net45))
          end
        end

        context 'and x64 version of windows is used' do
          let(:dir) { 'C:\Program Files (x86)\MSBuild\12.0\Bin' }
          let(:file) { 'MSBuild.exe' }
          before :each do
            mock_env('ProgramFiles(x86)', 'C:\Program Files (x86)')
            FileUtils.mkdir_p(dir)
            File.new(File.join(dir, file), 'w')
          end

          it 'then returns new msbuild from program files x86 by default' do
            expect(local(nil, :@exe)).to eq(testcase(:x64_net451))
          end

          it 'then returns new msbuild from program files x86 for :net451' do
            expect(local(:net451, :@exe)).to eq(testcase(:x64_net451))
          end

          it 'then returns new msbuild from program files x86 for :net45' do
            expect(local(:net45, :@exe)).to eq(testcase(:x64_net45))
          end
        end
      end

      context 'and old .net framework needed' do
        let(:dir) { 'C:\WINDOWS/Microsoft.NET/Framework/v4.0.30319' }
        let(:file) { 'MSBuild.exe' }
        before :each do
          FileUtils.mkdir_p(dir)
          File.new(File.join(dir, file), 'w')
        end

        it 'then returns msbuild from windows folder for :net40' do
          expect(local(:net40, :@exe)).to eq(testcase(:net40))
        end

        it 'then returns msbuild from windows folder for :net4' do
          expect(local(:net4, :@exe)).to eq(testcase(:net4))
        end
      end

      context 'and too old .net framework requested' do
        it 'then fails with RuntimeError' do
          expect { Alpaca::MSBuild.new(:net35) }.to raise_error
        end
      end

      context 'and wrong .net framework requested' do
        it 'then fails with RuntimeError' do
          expect { Alpaca::MSBuild.new(:wrongNetFramework) }.to raise_error
        end
      end
    end

    context 'when used on non windows system' do
      before :each do
        mock_os(:macos)
      end

      it 'then fails with RuntimeError' do
        expect { Alpaca::MSBuild.new }.to raise_error
      end
    end
  end

  describe '#run' do
    let(:file) { 'src/TestSolution.sln' }
    before :each do
      mock_os(:windows)
      dir = 'C:\Program Files\MSBuild\12.0\Bin'
      mock_env('ProgramFiles(x86)', nil)
      FileUtils.mkdir_p(dir)
      File.new(File.join(dir, 'MSBuild.exe'), 'w')
    end

    context 'when file passed with a block as a parameter' do
      subject { Alpaca::MSBuild.new }
      let(:result) do
        r = 'C:/Program Files/MSBuild/12.0/Bin/MSBuild.exe '
        r += ' src/TestSolution.sln /Verbosity:minimal '
        r += '/Property:Configuration=Debug'
        r += ' /Target:Clean;Rebuild'
        r
      end

      it 'executes msbuild.exe against file with configuration from block' do
        expect(subject).to receive(:`).with(result)
        allow(subject).to receive(:puts)
        subject.run(file) do
          configure(verbosity: 'minimal',
                    property: { Configuration: 'Debug' },
                    target: %w(Clean Rebuild))
        end
      end

      it 'and do same if use set_property for /Property' do
        expect(subject).to receive(:`).with(result)
        allow(subject).to receive(:puts)
        subject.run(file) do
          configure(verbosity: 'minimal')
          set_property('Configuration', 'Debug')
          configure(target: %w(Clean Rebuild))
        end
      end
    end
  end
end
