require 'yaml'

module AlpacaBuildTool
  # Version contains semantic version and methods
  # for updating it
  class Version
    attr_reader :major, :minor, :patch, :special, :metadata, :file
    attr_writer :metadata

    ##
    # PreRelease acceptable tags
    PRE_RELEASE = %w(alpha beta rc)

    errors = %w(InvalidFile WrongDimension AlreadyPreRelease AlreadyRelease
                FileNotFound MajorVersionNotInt MinorVersionNotInt
                PatchVersionNotInt SpecialNotRecognized NotPreRelease
                PreReleaseTagReachedFinalVersion)
    errors.each { |error| const_set(error, Class.new(StandardError)) }

    ##
    # Creates new instance
    #
    # +hash+:: Hash with version data:
    # :file - file with path to .semver file
    # :major - major version
    # :minor - minor version
    # :patch - patch version
    # :special - special version
    # :metadata - metadata
    def initialize(hash)
      @file = hash.fetch(:file) { fail InvalidFile }
      @major = hash.fetch(:major) { fail InvalidFile }
      @minor = hash.fetch(:minor) { fail InvalidFile }
      @patch = hash.fetch(:patch) { fail InvalidFile }
      @special = hash.fetch(:special) { fail InvalidFile }
      @metadata = hash.fetch(:metadata) { fail InvalidFile }
      validate
    end

    ##
    # Formatting version to string
    #
    # +format+:: format of version representation
    # %M - Major
    # %m - Minor
    # %p - Patch
    # %s - Special (adds '-')
    # %d - Metadata (adds '+')
    #
    #   v.inspect
    #     # =>  #<AlpacaBuildTool::Version:0x000000031aca90
    #     #       @file="d:/Learning/Ruby/alpaca/.semver",
    #     #       @major=1,
    #     #       @minor=2,
    #     #       @patch=3,
    #     #       @special="rc",
    #     #       @metadata="03fb4">
    #   v.format 'v%M.%m.%p%s%d'
    #     # => "v1.2.3-rc+03fb4"
    def to_s(format = 'v%M.%m.%p%s%d')
      result = format.gsub '%M', @major.to_s
      result.gsub! '%m', @minor.to_s
      result.gsub! '%p', @patch.to_s
      result.gsub!('%s', prerelease? ? "-#{@special}" : '')
      result.gsub!('%d', metadata? ? "+#{@metadata}" : '')
      result
    end

    ##
    # Returns yaml representation that can be stored to .semver file
    def to_yaml
      YAML.dump(major: @major, minor: @minor, patch: @patch,
                special: @special, metadata: @metadata)
    end

    ##
    # Returns true if #special isn't empty. Otherwise, false.
    def prerelease?
      !@special.nil? && !@special.empty?
    end

    ##
    # Returns true if #metadata isn't empty. Otherwise, false.
    def metadata?
      !@metadata.nil? && !@metadata.empty?
    end

    ##
    # Increase version following semantic version rules
    #
    # +dimension+:: one of the dimensions:
    #   :major       # increase major and reset lower versions
    #   :minor       # increase minor and reset lower versions
    #   :patch       # increase patch and reset lower versions
    #   :prerelease  # increase prerelease tag
    def increase(dimension)
      case dimension
      when :major then increase_major
      when :minor then increase_minor
      when :patch then increase_patch
      when :prerelease then increase_prerelease
      else fail WrongDimension
      end
    end

    ##
    # Set version to prerelease by adding 'alpha' to special
    def make_prerelease
      fail AlreadyPreRelease if prerelease?
      @special = PRE_RELEASE.first
    end

    ##
    # Clear special and metadata so version become higher and not prerelease
    def release
      fail AlreadyRelease unless prerelease?
      @special = ''
      @metadata = ''
    end

    private

    def validate
      fail FileNotFound unless File.exist?(@file)
      fail MajorVersionNotInt unless @major.is_a?(Integer)
      fail MinorVersionNotInt unless @minor.is_a?(Integer)
      fail PatchVersionNotInt unless @patch.is_a?(Integer)
      fail SpecialNotRecognized unless valid_special?
    end

    def valid_special?
      !prerelease? || PRE_RELEASE.include?(@special)
    end

    def increase_major
      @major += 1
      @minor = 0
      @patch = 0
    end

    def increase_minor
      @minor += 1
      @patch = 0
    end

    def increase_patch
      @patch += 1
    end

    def increase_prerelease
      fail NotPreRelease unless prerelease?
      tmp = ''
      PRE_RELEASE.each do |version|
        if @special == tmp
          @special = version
          return 0
        end
        tmp = version
      end
      fail PreReleaseTagReachedFinalVersion
    end
  end
end
