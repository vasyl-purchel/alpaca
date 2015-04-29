module AlpacaBuildTool
  ##
  # VisualStudioProject provides project representation and methods
  # to modify it's AssemblyVersion.cs file
  class Project
    attr_accessor :name, :file, :dir

    ##
    # Creates instance of class
    #
    # +line+:: line from .sln file with project information
    # +dir+:: solution directory
    #
    #   s = AlpacaBuildTool::VisualStudioProject.new(
    #     'Project("{FAE04EC0...5254043711}"'
    #     'd:\')
    #     # => #<**:VisualStudioProject:** @file="d:/sln1/some.csproj" **>
    def initialize(line, dir)
      items = line.gsub(/".*?"/).to_a
      _, @name, file, _ = items.map { |item| item.to_s.gsub('"', '') }
      dir = File.expand_path(dir)
      @dir = File.dirname(File.join(dir, file))
      @file = File.join(dir, file)
    end

    ##
    # Overrides *to_s* method to provide nice convertion to string
    def to_s
      "{#{@name};#{@file}}"
    end

    ##
    # Updates AssemblyInfo.cs file under the project with new_version
    #
    # +new_version+:: version that need to be used as assembly version
    # and assembly file version
    def update_version(new_version)
      info_file = File.join(@dir, 'Properties', 'AssemblyInfo.cs')
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
  end
end
