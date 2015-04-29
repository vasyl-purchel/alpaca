require 'spec_helper'
require 'alpacabuildtool/versioning/versioning'
require 'fakefs/spec_helpers'

describe AlpacaBuildTool::Versioning do
  include FakeFS::SpecHelpers
  describe '::init' do
    let(:content) do
      "---\n:major: 0\n:minor: 0\n:patch: 0\n:special: ''\n:metadata: ''\n"
    end

    context 'When base directory not passed' do
      let(:file) { '.semver' }
      subject { AlpacaBuildTool::Versioning.init }
      before(:each) { subject }

      it 'Creates new .semver file in current directory' do
        expect(File.exist?(file)).to be true
      end

      it 'Stores versioning information to .semver file' do
        expect(File.read(file)).to eq content
      end

      it 'Returns instance of Version class' do
        expect(subject).to be_an_instance_of(AlpacaBuildTool::Version)
      end

      it 'with 0 major version' do
        expect(subject.major).to eq 0
      end

      it 'with 0 minor version' do
        expect(subject.minor).to eq 0
      end

      it 'with 0 patch version' do
        expect(subject.patch).to eq 0
      end

      it 'with empty special' do
        expect(subject.special).to eq ''
      end

      it 'with empty metadata' do
        expect(subject.metadata).to eq ''
      end
    end

    context 'When base directory passed' do
      let(:file) { 'funny_dir/.semver' }
      subject { AlpacaBuildTool::Versioning.init 'funny_dir' }
      before(:each) { subject }

      it 'Creates new .semver file in specific directory' do
        expect(File.exist?(file)).to be true
      end

      it 'Stores versioning information to .semver file' do
        expect(File.read(file)).to eq content
      end

      it 'Returns instance of Version class' do
        expect(subject).to be_an_instance_of(AlpacaBuildTool::Version)
      end

      it 'with 0 major version' do
        expect(subject.major).to eq 0
      end

      it 'with 0 minor version' do
        expect(subject.minor).to eq 0
      end

      it 'with 0 patch version' do
        expect(subject.patch).to eq 0
      end

      it 'with empty special' do
        expect(subject.special).to eq ''
      end

      it 'with empty metadata' do
        expect(subject.metadata).to eq ''
      end
    end
  end

  describe '::find' do
    let(:file) { '.semver' }
    let(:content) do
      "---\n:major: 1\n:minor: 2\n:patch: 3\n:special: 'rc'\n:metadata: 'e4'\n"
    end

    context 'When base directory not passed' do
      subject { AlpacaBuildTool::Versioning.find }
      before(:each) do
        open(file, 'w') { |io| io.write content }
        subject
      end

      it 'Then returns Version instance' do
        expect(subject).to be_an_instance_of(AlpacaBuildTool::Version)
      end
    end

    context 'When base directory is passed' do
      let(:dir) { 'funny' }
      subject { AlpacaBuildTool::Versioning.find nil, dir }
      before(:each) do
        FileUtils.mkdir_p(dir)
        open(File.join(dir, file), 'w') { |io| io.write content }
        subject
      end

      it 'Then returns Version instance' do
        expect(subject).to be_an_instance_of(AlpacaBuildTool::Version)
      end
    end

    context 'When file does not found' do
      let(:dir) { 'funny' }
      subject { AlpacaBuildTool::Versioning.find nil, dir }
      before(:each) do
        open(file, 'w') { |io| io.write content }
      end

      it 'Then fails with SemVerFileNotFound' do
        expect { subject }
          .to raise_error AlpacaBuildTool::Versioning::SemVerFileNotFound
      end
    end

    context 'When file is corrupted' do
      let(:corrupted_content) do
        "---\n:major: 1\n:patch: 3\n:special: 'rc'\n:metadata: 'e4'\n"
      end
      subject { AlpacaBuildTool::Versioning.find }
      before(:each) do
        open(file, 'w') { |io| io.write corrupted_content }
      end

      it 'Then fails with InvalidSemVerFile' do
        expect { subject }.to raise_error AlpacaBuildTool::Version::InvalidFile
      end
    end

    context 'When solution folder passed' do
      let(:sln) do
        cur = File.dirname(File.expand_path(__FILE__))
        File.join(cur, '../test_data/sln1')
      end
      subject { AlpacaBuildTool::Versioning.find sln }
      before(:each) do
        FileUtils.mkdir_p(sln)
        open(File.join(sln, file), 'w') { |io| io.write content }
      end

      it 'Then returns Version instance' do
        expect(subject).to be_an_instance_of(AlpacaBuildTool::Version)
      end
    end
  end

  describe '::save' do
    let(:version) do
      AlpacaBuildTool::Version.new(file: '.semver',
                                   major: 1, minor: 2, patch: 3,
                                   special: 'rc', metadata: '4e')
    end
    let(:content) do
      "---\n:major: 1\n:minor: 2\n:patch: 3\n:special: rc\n:metadata: 4e\n"
    end
    before(:each) do
      open('.semver', 'w') { |io| io.write 'bad text' }
      AlpacaBuildTool::Versioning.save version
    end
    it 'Then write into file used to initialize version' do
      expect(File.exist?('.semver')).to be true
    end

    it 'And save semantic version data into file used for initialization' do
      expect(File.read(version.file)).to eq content
    end

    context 'When file name passed as argument' do
      it 'Then write into specified file' do
        open('.semver', 'w') { |io| io.write 'bad text' }
        AlpacaBuildTool::Versioning.save version, 'new.semver'
        expect(File.exist?('new.semver')).to be true
      end
    end
  end
end
