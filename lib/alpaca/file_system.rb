require 'pathname'

module Alpaca
  # The *FileSystem* module provides extended methods on files
  module FileSystem
    # Returns path to file with reverse search from current working
    # directory to the root directory. If file not found then returns nil
    #
    # +name+:: name of the file
    # +[dir]+:: base directory to look for file(empty by default)
    # +[cur]+:: start directory for the search(current working directory by
    # default)
    #
    #   # note: current working directory is d:\alpaca
    #   FileSystem::find('.semver')
    #     # => d:\alpaca\.semver
    #   FileSystem::find('alpaca.yml', 'bin')
    #     # => d:\alpaca\bin\alpaca.yml
    def self.find(name, dir = '', cur = Pathname.new('.'))
      file = File.join(cur.expand_path, dir, name)
      return file if File.exist?(file)
      return nil if cur.expand_path.root?
      File.find(name, dir, cur.parent)
    end
  end
end
