require 'alpacabuildtool/entities/xml_node'

module AlpacaBuildTool
  ##
  # Xml represents simple xml document with one root node
  #
  #    doc = Xml.new '1.0' do
  #      node 'a', 'b'
  #    end
  #    doc.to_s
  #    # => <?xml version="1.0"?>
  #    #    <a>b</a>
  class Xml
    ##
    # Creates instance
    #
    # +version+:: xml version
    # accepts &block
    def initialize(version, &block)
      @version, @root_node = version, nil
      instance_eval(&block) if block_given?
    end

    ##
    # Set/override root node
    #
    # +name+:: node name
    # +content+:: node content
    # accepts &block
    def node(name, content = nil, &block)
      @root = XmlNode.new(name, content, &block)
    end

    ##
    # Overrides string representation to generate xml document content from
    # stored objects
    def to_s
      "<?xml version=\"#{@version}\"?>\n#{@root}"
    end
  end
end
