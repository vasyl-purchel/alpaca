require 'alpaca/base/command_line_tool'

module Alpaca
  # The *Gerrit* class provides methods to:
  # - update gerrit review labels
  # - create new project in gerrit(new repository)
  class Gerrit
    include CommandLineTool

    # Creates instance of class
    #
    # +host+:: gerrit host
    # +port+:: port open for connections
    # +key+:: private ssh key for the user
    # +user+:: user name
    #
    #   g = Alpaca::Gerrit.new 'gerrit.com', '80', '~/.ssh/id_rsa', 'vasyl'
    def initialize(host, port, key, user)
      @host, @port, @key, @user = host, port, key, user
      base = %W(ssh -i #{@key} #{@user}@#{@host} -p #{@port} gerrit)
      super(base.join(' '), '--', ' ', false)
    end

    # Update label for gerrit review
    #
    # +label+:: label that need to be updated
    # +value+:: value for the label (-2, -1, 0, 1, 2)
    # +revision+:: review identifier for label to be updated on
    def review(label, value, revision)
      run 'review', revision, label: "#{label}=#{value}"
    end

    # Create new gerrit project/repository
    #
    # +name+:: name of the project
    # +parent+:: parent project to inherit access rights from
    # +[description]+:: description of the project
    #
    #   g.create_project 'rubytools\alpaca', 'rubytools\acls'
    def create_project(name, parent, description = nil)
      config = { parent: parent }
      config[:description] = description if description
      run 'create-project', name, config
    end
  end
end
