require 'fileutils'
require 'yaml'
require 'pathname'
require 'alpaca/errors'
require 'alpaca/entities/version'

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
    # +[solution_folder]+:: directory from which to start searching
    #  .semver file(nil by default)
    # +[dir]+:: base directory for .semver file(current working
    # directory by default)
    def self.find(solution_folder = nil, dir = '')
      solution_folder = Pathname.new(solution_folder) if solution_folder
      semver = find_file FILE_NAME, dir, solution_folder || Pathname.new('.')
      fail Errors::SemVerFileNotFound if semver.nil?
      hash = YAML.load_file(semver) || {}
      hash[:file] = semver
      Version.new hash
    end

    # Helper method to recursivly find file
    #
    # +name+:: file name to find
    # +dir+:: relative path to file
    # +cur+:: current folder to start searching from
    def self.find_file(name, dir, cur)
      file = File.join(cur.expand_path, dir, name)
      return file if File.exist?(file)
      return nil if cur.expand_path.root?
      find_file(name, dir, cur.parent)
    end

    # Returns Version instance from specific file
    #
    # +[file]+:: path to file that contains .semver content
    def self.parse(file)
      hash = YAML.load_file(file)
      hash[:file] = file
      Version.new hash
    end

    # Save changes done to version
    #
    # +version+:: instance of Version class
    # +file+:: specific file to save to(nil by default)
    def self.save(version, file = nil)
      file ||= version.file
      open(file, 'w') { |io| io.write version.to_yaml }
    end
  end
end
