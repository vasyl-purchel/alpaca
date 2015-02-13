require_relative '../../lib/alpaca/msbuild'
require_relative '../../lib/alpaca/msbuildconfig'
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
  c.include Helpers
  c.include TestCases
end

describe Alpaca::MSBuild do
  describe '#executable' do
    def testcase(key)
      normalize_path(test_cases[key])
    end

    context 'when used on windows system' do
      before :each do
        mock_os(:windows)
        subject.instance_variable_set :@win_dir, nil
        subject.instance_variable_set :@program_files_dir, nil
      end

      context 'and new .net framework needed' do
        context 'and x86 version of windows is used' do
          before :each do
            mock_env('ProgramFiles(x86)', nil)
            mock_file(/.*MSBuild.exe/)
          end

          it 'then returns new msbuild from program files by default' do
            expect(subject.executable.downcase)
              .to eq(testcase(:x86_net451))
          end

          it 'then returns new msbuild from program files for :net451' do
            expect(subject.executable(:net451).downcase)
              .to eq(testcase(:x86_net451))
          end

          it 'then returns new msbuild from program files for :net45' do
            expect(subject.executable(:net45).downcase)
              .to eq(testcase(:x86_net45))
          end
        end

        context 'and x64 version of windows is used' do
          before :each do
            mock_env('ProgramFiles(x86)', 'c:\pf (x86)')
            mock_directory('c:\pf (x86)')
            mock_file(/.*MSBuild.exe/)
          end

          it 'then returns new msbuild from program files x86 by default' do
            expect(subject.executable.downcase)
              .to eq(testcase(:x64_net451))
          end

          it 'then returns new msbuild from program files x86 for :net451' do
            expect(subject.executable(:net451).downcase)
              .to eq(testcase(:x64_net451))
          end

          it 'then returns new msbuild from program files x86 for :net45' do
            expect(subject.executable(:net45).downcase)
              .to eq(testcase(:x64_net45))
          end
        end
      end

      context 'and old .net framework needed' do
        before :each do
          mock_file(/.*MSBuild.exe/)
        end

        it 'then returns msbuild from windows folder for :net40' do
          expect(subject.executable(:net40).downcase)
            .to eq(testcase(:net40))
        end

        it 'then returns msbuild from windows folder for :net4' do
          expect(subject.executable(:net4).downcase)
            .to eq(testcase(:net4))
        end
      end

      context 'and too old .net framework requested' do
        it 'then fails with RuntimeError' do
          expect { subject.executable(:net35) }.to raise_error
        end
      end

      context 'and wrong .net framework requested' do
        it 'then fails with RuntimeError' do
          expect { subject.executable(:wrongNetFramework) }.to raise_error
        end
      end
    end

    context 'when used on non windows system' do
      before :each do
        mock_os(:macos)
      end

      it 'then fails with RuntimeError' do
        expect { subject.executable }.to raise_error
      end
    end
  end

  describe Alpaca::MSBuild::Config do
    let(:file) { 'src/TestSolution.sln' }
    describe '#new' do
      context 'when only file passed as a parameter' do
        subject { Alpaca::MSBuild::Config.new(file) }
        it 'then creates new MSBuild::Config object' do
          expect(subject).to be_an_instance_of(Alpaca::MSBuild::Config)
        end

        it 'then set @file to test solution file' do
          expect(subject.file).to be(file)
        end
      end

      context 'when file passed with a block as a parameter' do
        subject do
          Alpaca::MSBuild::Config.new(file) do
            configure(verbosity: 'minimal')
            configure(property: { 'Configuration' => 'Debug' })
            configure(target: %w(Clean Rebuild))
          end
        end

        it 'then creates new MSBuild::Config object' do
          expect(subject).to be_an_instance_of(Alpaca::MSBuild::Config)
        end

        it 'then set @file to test solution file' do
          expect(subject.file).to be(file)
        end

        it 'then set @verbosity to be minimal' do
          expect(subject.verbosity).to eq('minimal')
        end

        it 'then set @target to be Clean and Rebuild' do
          expect(subject.target).to eq(%w(Clean Rebuild))
        end
      end
    end

    describe '#args' do
      context 'when verbosity, propertн and target are set' do
        subject do
          Alpaca::MSBuild::Config.new(file) do
            configure(verbosity: 'minimal')
            configure(property: { 'Configuration' => 'Debug' })
            configure(target: %w(Clean Rebuild))
          end
        end

        it 'returns array of argumens for MSBuild.exe' do
          expect(subject.args).to be_an_instance_of(Array)
        end

        it 'returns array that include verbosity' do
          expect(subject.args).to include('/Verbosity:minimal')
        end

        it 'returns array that include properties' do
          expect(subject.args).to include('/Property:Configuration=Debug')
        end

        it 'returns array that include targets' do
          expect(subject.args).to include('/Target:Clean;Rebuild')
        end
      end
    end

    describe '#to_s' do
      let(:result) do
        a = %W(#{file} /Verbosity:minimal)
        a += %w(/Property:Configuration=Debug /Target:Clean;Rebuild)
        a.join(' ')
      end
      subject do
        Alpaca::MSBuild::Config.new(file) do
          configure(verbosity: 'minimal')
          configure(property: { 'Configuration' => 'Debug' })
          configure(target: %w(Clean Rebuild))
        end
      end
      it 'returns all #args with space delimeter' do
        expect(subject.to_s).to eq(result)
      end
    end
  end
end
