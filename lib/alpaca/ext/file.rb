require 'pathname'

# Just a container for find_file method to be used for File.find
module Alpaca
  # Returns path to file with reverse search from current working
  # directory to the root directory. If file not found then returns nil
  #
  # +name+:: name of the file
  # +[dir]+:: base directory to look for file(empty by default)
  # +[cur]+:: start directory for the search(current working directory by
  # default)
  #
  #   # note: current working directory is d:\alpaca
  #   File.find('.semver')
  #     # => d:\alpaca\.semver
  #   File.find('alpaca.yml', 'bin')
  #     # => d:\alpaca\bin\alpaca.yml
  def self.find_file(name, dir = '', cur = Pathname.new('.'))
    file = File.join(cur.expand_path, dir, name)
    return file if File.exist?(file)
    return nil if cur.expand_path.root?
    find_file(name, dir, cur.parent)
  end
end

def File.find(name, dir = '', cur = Pathname.new('.'))
  Alpaca.find_file(name, dir, cur)
end
