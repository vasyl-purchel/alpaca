module AlpacaBuildTool
  ##
  # Git provides methods to help with git version control tool
  module Git
    ##
    # Returns string with changes in dir
    #
    # +dir+:: specific dir where to look for changes
    # +commit_from+:: commit from which look for changes(nil by default to
    # look for all changes)
    def self.changes(dir, commit_from = nil)
      return `git log -- #{dir}` unless commit_from
      `git log #{commit_from}..HEAD -- #{dir}`
    end

    ##
    # Returns current revision id
    def self.revision
      `git rev-parse HEAD`
    end
  end
end
