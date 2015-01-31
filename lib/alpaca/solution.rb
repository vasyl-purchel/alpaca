require_relative 'msbuild'
require_relative 'msbuildconfig'

module Alpaca
  # some description for solution
  class Solution
    attr_accessor :file, :build_tool

    def initialize(file, netversion = :net45)
      @file = file
      @build_tool = MSBuild.executable netversion
    end

    def to_s
      @file.to_s
    end

    def compile(configuration = :Release)
      config = MSBuild::Config.new(@file) do |c|
        c.verbosity = 'minimal'
        c.properties = { 'Configuration' => configuration }
        c.targets = %w(Clean Rebuild)
      end
      system @build_tool, *(config.args)
    end
  end
end
