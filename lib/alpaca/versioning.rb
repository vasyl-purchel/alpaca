require_relative 'errors'
require_relative 'version'
require 'fileutils'

module Alpaca
  # The *Versioning* provides methods to load and save version
  # for solutions
  module Versioning
    FILE_NAME = '.semver'

    # Initializes semantic versioning
    #
    # +[dir]+:: directory where to place .semver(current working
    # directory by default)
    def self.init(dir = '')
      hash = { major: 0, minor: 0, patch: 0, special: '', metadata: '' }
      FileUtils.mkdir_p(dir) unless File.directory?(dir)
      file = File.join dir, FILE_NAME
      open(file, 'w') { |io| io.write YAML.dump(hash) }
      hash[:file] = file
      Version.new hash
    end

    # Returns Version instance from .semver file found
    # by reverse search from current working directory/dir
    # up to root directory
    #
    # +[dir]+:: base directory for .semver file(current working
    # directory by default)
    def self.find(dir = '')
      semver = FileSystem.find FILE_NAME, dir
      fail Errors::SemVerFileNotFound if semver.nil?
      hash = YAML.load_file(semver) || {}
      hash[:file] = semver
      Version.new hash
    end

    # Save changes done to version
    #
    # +version+:: instance of Version class
    def self.save(version, file = nil)
      file ||= version.file
      open(file, 'w') { |io| io.write version.to_yaml }
    end
  end
end
