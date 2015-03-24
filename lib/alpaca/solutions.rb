require 'alpaca/entities/visual_studio_solution'
require 'alpaca/entities/unity_solution'

module Alpaca
  # The *Solutions* module provides method to find
  # solutions to current directory
  class Solutions
    # Yields solutions for given pattern
    #
    # +pattern+:: pattern to search for solution files
    #
    #   Solutions.each '**/*.sln' do |f|
    #     # do some awesome stuff with solution f
    #   end
    def self.each(pattern)
      Dir.glob(pattern).each do |f|
        yield VisualStudioSolution.new(f) if visual_studio? f
        yield UnitySolution.new(f) if unity? f
      end
    end

    # Check if file is VisualStudio solution file
    #
    # +file+:: file to check
    def self.visual_studio?(file)
      return false unless File.file? file
      file.end_with? '.sln'
    end

    # Check if assets_folder is from Unity3D project folder
    #
    # +assets_folder+:: folder to check
    def self.unity?(assets_folder)
      return false unless File.directory? assets_folder
      project_dir = File.dirname assets_folder
      settings_folder = File.join project_dir, 'ProjectSettings'
      File.directory? settings_folder
    end
  end
end
