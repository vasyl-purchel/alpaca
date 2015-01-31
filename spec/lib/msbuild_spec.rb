require_relative '../../lib/alpaca/msbuild'
require_relative 'spec_helper'

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
        subject.backdoor do
          @win_dir = nil
          @program_files_dir = nil
        end
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
end
