require 'alpaca/base/command_line_tool'
require 'alpaca/camelize_name_formatter'

module Alpaca
  # The *Nuget* class provides a wraper for
  # Nuget.exe (https://www.nuget.org/)
  class Nuget
    include CommandLineTool

    # Creates instance of class
    #
    # +exe+:: path to Nuget.exe
    # +[config]+:: path to Nuget.config(optional)
    #
    #   n = Alpaca::Nuget.new 'c:/nuget/nuget.exe', 'c:/nuget/nuget.config'
    def initialize(exe, config = nil)
      super(exe, '-', ' ', true, CamelizeNameFormatter.new)
      @config = config
    end

    # Promote nuget package(not part of nuget.exe)
    # Promotion is updating nuget package version
    # from alpha to beta, from beta to rc and from rc to release.
    #
    # +id_or_file+:: package id or .nupkg file to be promoted
    # +[version]+:: package version to be promoted(by default nil)
    # +&block+:: accepts block with configuration
    #
    #   n.promote 'alpaca.0.0.1-alpha005.nupkg'
    #     # => "alpaca.0.0.1-beta001.nupkg"
    #   n.promote 'alpaca', '0.0.1-beta001'
    def promote(id_or_file, version = nil, &block)
      info("#{id_or_file} with #{version} will be promoted")
      instance_eval(&block) if block_given?
    end

    # Executes command for Nuget.exe
    #
    # +command+:: command(install, pack, push, restore, update, spec)
    # +argument+:: argument for the command(packageId, config file, etc.)
    # +&block+:: accepts block with configuration
    #
    #   n.run 'install', 'alpaca' do
    #     configure(no_cache: true)
    #   end
    #     # => nuget.exe install alpaca -NoCache
    def run(command, argument, &block)
      super command, argument do
        instance_eval(&block) if block_given?
        if @config && !(@config_file || @ConfigFile)
          configure(config_file: @config)
        end
      end
    end
  end
end
