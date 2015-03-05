require 'fakefs/spec_helpers'
require 'alpaca/errors'
require 'alpaca/versioning'

describe Alpaca::Versioning do
  include FakeFS::SpecHelpers
  module FakeFS
    # Extending FakeFS to File.find method
    class File
      def self.find(name, dir = '', cur = Pathname.new('.'))
        Alpaca.find_file(name, dir, cur)
      end
    end
  end
  describe '::init' do
    let(:content) do
      "---\n:major: 0\n:minor: 0\n:patch: 0\n:special: ''\n:metadata: ''\n"
    end

    context 'When base directory not passed' do
      let(:file) { '.semver' }
      subject { Alpaca::Versioning.init }
      before(:each) { subject }

      it 'Creates new .semver file in current directory' do
        expect(File.exist?(file)).to be true
      end

      it 'Stores versioning information to .semver file' do
        expect(File.read(file)).to eq content
      end

      it 'Returns instance of Version class' do
        expect(subject).to be_an_instance_of(Alpaca::Version)
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
      subject { Alpaca::Versioning.init 'funny_dir' }
      before(:each) { subject }

      it 'Creates new .semver file in specific directory' do
        expect(File.exist?(file)).to be true
      end

      it 'Stores versioning information to .semver file' do
        expect(File.read(file)).to eq content
      end

      it 'Returns instance of Version class' do
        expect(subject).to be_an_instance_of(Alpaca::Version)
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
      subject { Alpaca::Versioning.find }
      before(:each) do
        open(file, 'w') { |io| io.write content }
        subject
      end

      it 'Then returns Version instance' do
        expect(subject).to be_an_instance_of(Alpaca::Version)
      end
    end

    context 'When base directory is passed' do
      let(:dir) { 'funny' }
      subject { Alpaca::Versioning.find nil, dir }
      before(:each) do
        FileUtils.mkdir_p(dir)
        open(File.join(dir, file), 'w') { |io| io.write content }
        subject
      end

      it 'Then returns Version instance' do
        expect(subject).to be_an_instance_of(Alpaca::Version)
      end
    end

    context 'When file does not found' do
      let(:dir) { 'funny' }
      subject { Alpaca::Versioning.find nil, dir }
      before(:each) do
        open(file, 'w') { |io| io.write content }
      end

      it 'Then fails with SemVerFileNotFound' do
        expect { subject }.to raise_error Alpaca::Errors::SemVerFileNotFound
      end
    end

    context 'When file is corrupted' do
      let(:corrupted_content) do
        "---\n:major: 1\n:patch: 3\n:special: 'rc'\n:metadata: 'e4'\n"
      end
      subject { Alpaca::Versioning.find }
      before(:each) do
        open(file, 'w') { |io| io.write corrupted_content }
      end

      it 'Then fails with InvalidSemVerFile' do
        expect { subject }.to raise_error Alpaca::Errors::InvalidSemVerFile
      end
    end

    context 'When solution folder passed' do
      let(:sln) do
        cur = File.dirname(File.expand_path(__FILE__))
        File.join(cur, '../test_data/sln1')
      end
      subject { Alpaca::Versioning.find sln }
      before(:each) do
        FileUtils.mkdir_p(sln)
        open(File.join(sln, file), 'w') { |io| io.write content }
      end

      it 'Then returns Version instance' do
        expect(subject).to be_an_instance_of(Alpaca::Version)
      end
    end
  end

  describe '::save' do
    let(:version) do
      Alpaca::Version.new(file: '.semver',
                          major: 1, minor: 2, patch: 3,
                          special: 'rc', metadata: '4e')
    end
    let(:content) do
      "---\n:major: 1\n:minor: 2\n:patch: 3\n:special: rc\n:metadata: 4e\n"
    end
    before(:each) do
      open('.semver', 'w') { |io| io.write 'bad text' }
      Alpaca::Versioning.save version
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
        Alpaca::Versioning.save version, 'new.semver'
        expect(File.exist?('new.semver')).to be true
      end
    end
  end
end

describe Alpaca::Version do
  include FakeFS::SpecHelpers
  def set_version(a, b, c, d, e)
    open('.semver', 'w') { |io| io.write 'mock file presense' }
    { file: '.semver', major: a, minor: b, patch: c, special: d, metadata: e }
  end

  describe '#increase :major' do
    it 'v1.2.3-rc+03fb4 -> v2.0.0-rc+03fb4' do
      v = Alpaca::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.increase :major
      expect(v.to_s).to eq 'v2.0.0-rc+03fb4'
    end
  end
  describe '#increase :minor' do
    it 'v1.2.3-rc+03fb4 -> v1.3.0-rc+03fb4' do
      v = Alpaca::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.increase :minor
      expect(v.to_s).to eq 'v1.3.0-rc+03fb4'
    end
  end
  describe '#increase :patch' do
    it 'v1.2.3-rc+03fb4 -> v1.2.4-rc+03fb4' do
      v = Alpaca::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.increase :patch
      expect(v.to_s).to eq 'v1.2.4-rc+03fb4'
    end
  end
  describe '#increase :prerelease' do
    it 'v1.2.3-alpha+03fb4 -> v1.2.3-beta+03fb4' do
      v = Alpaca::Version.new(set_version 1, 2, 3, 'alpha', '03fb4')
      v.increase :prerelease
      expect(v.to_s).to eq 'v1.2.3-beta+03fb4'
    end
    it 'v1.2.3-beta+03fb4 -> v1.2.3-rc+03fb4' do
      v = Alpaca::Version.new(set_version 1, 2, 3, 'beta', '03fb4')
      v.increase :prerelease
      expect(v.to_s).to eq 'v1.2.3-rc+03fb4'
    end
    it 'v1.2.3-rc+03fb4 -> fail PreReleaseTagReachedFinalVersion' do
      v = Alpaca::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      expect { v.increase :prerelease }
        .to raise_error(Alpaca::Errors::PreReleaseTagReachedFinalVersion)
    end
    it 'v1.2.3 -> fail NotPreRelease' do
      v = Alpaca::Version.new(set_version 1, 2, 3, '', '')
      expect { v.increase :prerelease }
        .to raise_error(Alpaca::Errors::NotPreRelease)
    end
  end
  describe '#metadata 334f666' do
    it 'v1.2.3-rc+03fb4 -> v1.2.3-rc+334f666' do
      v = Alpaca::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.metadata = '334f666'
      expect(v.to_s).to eq 'v1.2.3-rc+334f666'
    end
  end
  describe '#release' do
    it 'v1.2.3-rc+03fb4 -> v1.2.3' do
      v = Alpaca::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.release
      expect(v.to_s).to eq 'v1.2.3'
    end
    it 'v1.2.3 -> fail AlreadyReleaseVersion' do
      v = Alpaca::Version.new(set_version 1, 2, 3, '', '')
      expect { v.release }
        .to raise_error(Alpaca::Errors::AlreadyReleaseVersion)
    end
  end
  describe '#make_prerelease' do
    it 'v1.2.3-rc+03fb4 -> fail AlreadyPreReleaseVersion' do
      v = Alpaca::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.increase :major
      expect(v.to_s).to eq 'v2.0.0-rc+03fb4'
    end
    it 'v1.2.3 -> v1.2.3-alpha' do
      v = Alpaca::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.increase :major
      expect(v.to_s).to eq 'v2.0.0-rc+03fb4'
    end
  end
end
