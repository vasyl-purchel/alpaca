module Alpaca
  # Class *VisualStudioProject* provides project
  # representation and methods to manipulate it
  class VisualStudioProject
    # Creates instance of class
    #
    # +line+:: line from .sln file with project information
    # +dir+:: solution directory
    #
    #   s = Alpaca::VisualStudioProject.new(
    #     'Project("{FAE04EC0...5254043711}"'
    #     'd:\')
    #     # => #<**:VisualStudioProject:** @file="here/some.csproj" **>
    def initialize(line, dir)
      @dir = dir
      items = line.gsub(/".*?"/).to_a
      @id = chop(items[3])
      @name = chop(items[1])
      @file = chop(items[2])
    end

    # Overrides *to_s* method to provide nice convertion to string
    def to_s
      "{#{@name};#{@file}}"
    end

    # Updates AssemblyInfo.cs file under the project with new_version
    #
    # +new_version+:: version that need to be used as assembly version
    # and assembly file version
    def update_version(new_version)
      return if stub?
      dir = File.dirname(File.join(@dir, @file))
      info_file = File.join(dir, 'Properties', 'AssemblyInfo.cs')
      content = IO.readlines(info_file)
      open(info_file, 'w') do |io|
        content.each { |line| io.write replace_version(line, new_version) }
      end
    end

    private

    def replace_version(line, new_version)
      line = line.gsub(/AssemblyVersion\("(.*?)"\)/,
                       "AssemblyVersion(\"#{new_version}\")")
      line.gsub(/AssemblyFileVersion\("(.*?)"\)/,
                "AssemblyFileVersion(\"#{new_version}\")")
    end

    def chop(s)
      s.gsub('"', '')
    end

    def stub?
      @name == '.nuget'
    end
  end
end
