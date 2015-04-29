require 'alpacabuildtool/entities/xml'

module AlpacaBuildTool
  ##
  # Nuspec creates *.nuspec file content
  #
  #    Nuspec.new(id: 'Cool.Package',
  #               version: '0.0.1',
  #               description: 'something',
  #               authors: ['Vasyl', 'Kate'],
  #               false).to_s
  #    # => <?xml version="1.0"?>
  #    #    <package>
  #    #      <metadata>
  #    #        <id>Cool.Package</id>
  #    #        <version>0.0.1</version>
  #    #        <authors>Vasyl,Kate</authors>
  #    #        <description>something</description>
  #    #      </metadata>
  #    #    </package>
  class Nuspec
    OPTIONAL = %w(title licenseUrl projectUrl copyright iconUrl
                  requireLicenseAcceptance releaseNotes)

    ##
    # Creates instance and generate content from *package* config
    #
    # +package+:: package configuration
    # +add_common_files+:: flag to add files like README and CHANGELOG
    def initialize(package, add_common_files = true)
      @content = generate(package, add_common_files)
    end

    ##
    # Overrides to_s method to create string content from inner Xml object
    def to_s
      @content.to_s
    end

    ##
    # Returns Xml object representation of package nuspec
    #
    # +config+:: package configuration
    # +add_common_files+:: flag to add common files or not
    def generate(config, add_common_files)
      Xml.new '1.0' do
        node 'package' do |package|
          Nuspec.add_metadata(package, config)
          Nuspec.add_files(package, config) if add_common_files
        end
      end
    end

    ##
    # Adds metadata entry to nuspec
    #
    # +package+:: XmlNode where to add metadata
    # +config+:: package configuration
    def self.add_metadata(package, config)
      package.node 'metadata' do |metadata|
        Nuspec.add_mandatory_fields(metadata, config)
        Nuspec.add_optional_fields(metadata, config)
      end
    end

    ##
    # Adds mandatory entries to nuspec like id, version, authors and description
    #
    # +metadata+:: XmlNode where to add entries
    # +config+:: package configuration
    def self.add_mandatory_fields(metadata, config)
      metadata.node 'id', config['id']
      metadata.node 'version', config['version']
      metadata.node 'authors', config['authors'].join(',')
      metadata.node 'description', config['description']
    end

    ##
    # Adds optional entries to nuspec like owners, tags and so on
    #
    # +metadata+:: XmlNode where to add entries
    # +config+:: package configuration
    def self.add_optional_fields(metadata, config)
      OPTIONAL.each { |name| metadata.node(name, config[name]) if config[name] }
      metadata.node 'owners', config['owners'].join(',') if config['owners']
      metadata.node 'tags', config['tags'].join(' ') if config['tags']
    end

    ##
    # Adds README.txt and CHANGES.txt files
    #
    # +package+:: XmlNode where to add files entry
    # +config+:: package configuration
    def self.add_files(package, config)
      package.node 'files' do
        node 'file' do
          attribute 'src', 'README.txt'
          attribute 'target', ''
        end if config['readme']
        node 'file' do
          attribute 'src', 'CHANGES.txt'
          attribute 'target', ''
        end
      end
    end
  end
end
