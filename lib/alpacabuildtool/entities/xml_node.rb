require 'cgi'

module AlpacaBuildTool
  ##
  # XmlNode represents simple xml node that can contain attributes and other
  # nodes or string as a content
  class XmlNode
    attr_reader :name, :content

    ##
    # Creates an instance
    #
    # +name+:: name of node
    # +content+:: content of node (if set, block is ignored)
    # accepts &block to set content to array of nodes
    def initialize(name, content = nil, &block)
      @name = name
      return @content = content unless content.nil?
      return unless block_given?
      @arity = block.arity
      if @arity <= 0
        @context = eval('self', block.binding)
        instance_eval(&block)
      else
        yield self
      end
    end

    ##
    # Adds new node into content
    #
    # +name+:: node name
    # +content+:: node content
    # accepts &block for this new node
    #
    #    XmlNode.new 'a' do
    #      node 'b' do
    #        node 'c' do
    #          ...
    #        end
    #      end
    #    end
    def node(name, content = nil, &block)
      (@content ||= []) << XmlNode.new(name, content, &block)
    end

    ##
    # Adds attribute to node
    #
    # +name+:: attribute name
    # +value+:: attribute value
    def attribute(name, value)
      (@attributes ||= {})[name] = value
    end

    ##
    # Overrides string representation to populate xml pretty formatted content
    def to_s
      return "<#{@name}#{attributes_to_s}/>" if @content.nil?
      content = @content.is_a?(Array) ? array_to_s : CGI.escape_html(@content)
      "<#{@name}#{attributes_to_s}>#{content}</#{@name}>"
    end

    private

    def attributes_to_s
      (@attributes || {}).map { |n, v| " #{n}=\"#{v}\"" }.reduce(&:+)
    end

    def array_to_s
      nodes = @content.map { |n| "\t#{n}".gsub(/\n/, "\n\t") }
      "\n#{nodes.join("\n")}\n"
    end
  end
end
