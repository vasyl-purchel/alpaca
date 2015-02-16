require 'alpaca/base/logger'
module Alpaca
  # The *Solution* class provides method to:
  # - compile solution
  class Solution
    include Logger
    attr_accessor :file, :net_version
    attr_accessor :format_version
    attr_accessor :visual_studio_version, :minimum_visual_studio_version
    attr_accessor :projects

    # Creates instance of class
    #
    # +file+:: solution file
    #
    #   s = Alpaca::Solution.new 'some.sln'
    #     # => #<**:Solution:** @file="d:/some.sln" **>
    def initialize(file)
      @file = File.expand_path(file)
      fail "Can't find file #{@file}" unless File.exist?(@file)
      initialize_data
    end

    # Overrides *to_s* method to provide nice convertion to string
    # Returns multiple lines
    def to_s
      s = "------------\nFile: #{@file}"
      s += "\nFormat version: #{@format_version}"
      s += "\nVisual studio version: #{@visual_studio_version}"
      s += "\nMinimum visual studio version: #{@minimum_visual_studio_version}"
      s += "\nProjects:" unless @projects.empty?
      @projects.each { |p| s += "\n\t{#{p[:name]};#{p[:file]}}" }
      s += "\n------------"
      s
    end

    private

    def initialize_data
      @projects ||= []
      IO.readlines(@file).each do |line|
        if line.start_with?('Project')
          @projects << parse_project(line)
        else
          initialize_versions(line)
        end
      end
    end

    def initialize_versions(line)
      if line.match(/.*Format Version [\d\.]+/)
        @format_version = parse_version(line)
      elsif line.start_with?('VisualStudioVersion')
        @visual_studio_version = parse_version(line)
      elsif line.start_with?('MinimumVisualStudioVersion')
        @minimum_visual_studio_version = parse_version(line)
      end
    end

    def chop(s)
      s.gsub('"', '')
    end

    def parse_version(s)
      s.gsub(/[\d\.]+/).first
    end

    def parse_project(s)
      items = s.gsub(/".*?"/).to_a
      { id: chop(items[3]), name: chop(items[1]), file: chop(items[2]) }
    end
  end
end
