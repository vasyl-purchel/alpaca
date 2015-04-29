require 'spec_helper'
require 'alpacabuildtool/versioning/version'
require 'fakefs/spec_helpers'

describe AlpacaBuildTool::Version do
  include FakeFS::SpecHelpers
  def set_version(a, b, c, d, e)
    open('.semver', 'w') { |io| io.write 'mock file presense' }
    { file: '.semver', major: a, minor: b, patch: c, special: d, metadata: e }
  end

  describe '#increase :major' do
    it 'increase major and reset lover(v1.2.3-rc+03fb4 -> v2.0.0-rc+03fb4)' do
      v = AlpacaBuildTool::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.increase :major
      expect(v.to_s).to eq 'v2.0.0-rc+03fb4'
    end
  end
  describe '#increase :minor' do
    it 'increase monir and reset lover(v1.2.3-rc+03fb4 -> v1.3.0-rc+03fb4)' do
      v = AlpacaBuildTool::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.increase :minor
      expect(v.to_s).to eq 'v1.3.0-rc+03fb4'
    end
  end
  describe '#increase :patch' do
    it 'increase patch only(v1.2.3-rc+03fb4 -> v1.2.4-rc+03fb4)' do
      v = AlpacaBuildTool::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.increase :patch
      expect(v.to_s).to eq 'v1.2.4-rc+03fb4'
    end
  end
  describe '#increase :prerelease' do
    it 'update "alpha" to "beta"(v1.2.3-alpha+03fb4 -> v1.2.3-beta+03fb4)' do
      v = AlpacaBuildTool::Version.new(set_version 1, 2, 3, 'alpha', '03fb4')
      v.increase :prerelease
      expect(v.to_s).to eq 'v1.2.3-beta+03fb4'
    end
    it 'update "beta" to "rc"(v1.2.3-beta+03fb4 -> v1.2.3-rc+03fb4)' do
      v = AlpacaBuildTool::Version.new(set_version 1, 2, 3, 'beta', '03fb4')
      v.increase :prerelease
      expect(v.to_s).to eq 'v1.2.3-rc+03fb4'
    end
    it 'fail to increase "rc" as it is last pre-release stage' do
      v = AlpacaBuildTool::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      expect { v.increase :prerelease }.to raise_error(
        AlpacaBuildTool::Version::PreReleaseTagReachedFinalVersion)
    end
    it 'fail to increase prerelease tag for release package' do
      v = AlpacaBuildTool::Version.new(set_version 1, 2, 3, '', '')
      expect { v.increase :prerelease }
        .to raise_error(AlpacaBuildTool::Version::NotPreRelease)
    end
  end
  describe '#metadata 334f666' do
    it 'update metadata to new value' do
      v = AlpacaBuildTool::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.metadata = '334f666'
      expect(v.to_s).to eq 'v1.2.3-rc+334f666'
    end
  end
  describe '#release' do
    it 'Clean pre-release tag and metadata(v1.2.3-rc+03fb4 -> v1.2.3)' do
      v = AlpacaBuildTool::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.release
      expect(v.to_s).to eq 'v1.2.3'
    end
    it 'Fail to release version that is already released' do
      v = AlpacaBuildTool::Version.new(set_version 1, 2, 3, '', '')
      expect { v.release }
        .to raise_error(AlpacaBuildTool::Version::AlreadyRelease)
    end
  end
  describe '#make_prerelease' do
    it 'Fail to make version pre-release if it is already pre-release' do
      v = AlpacaBuildTool::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.increase :major
      expect(v.to_s).to eq 'v2.0.0-rc+03fb4'
    end
    it 'Add pre-release tag' do
      v = AlpacaBuildTool::Version.new(set_version 1, 2, 3, 'rc', '03fb4')
      v.increase :major
      expect(v.to_s).to eq 'v2.0.0-rc+03fb4'
    end
  end
end
