require_relative 'configurable'
require_relative 'executable'
require_relative 'versioning'

module Alpaca
  # The *Nuget* class provides methods to work with
  # Nuget.exe (https://www.nuget.org/)
  class Nuget
    include Configurable
    include Executable

    attr_accessor :exe, :config

    # Creates instance of class
    #
    # +exe+:: path to Nuget.exe
    # +[config]+:: path to Nuget.config(optional)
    # +&block+:: accepts block with configuration
    #
    #   n = Alpaca::Nuget.new 'c:/nuget/nuget.exe', 'c:/nuget/nuget.config'
    #
    # tip: &block is only for internal usage as nothing except *exe* and
    # *config* will be used for other commands
    def initialize(exe, config = nil)
      @exe = exe
      @config = config
    end

    # Install nuget package[s]
    #
    # +package_or_config+:: package id or path to packages.config file
    # with packages to be installed
    # +&block+:: accepts block with configuration
    #
    #   n.install 'Alpaca.Cool.Tool'
    #   n.install '/c/solution/.nuget/packages.config' do
    #     configure(no_cache: true)
    #   end
    def install(package_or_config, &block)
      common 'install', %W(#{package_or_config}), &block
    end

    # Restore nuget package[s]
    #
    # +solution_or_config+:: solution or path to packages.config file
    # with packages to be restored
    # +&block+:: accepts block with configuration
    #
    #   n.restore '/c/solution/solution.sln'
    #   n.restore '/c/solution/.nuget/packages.config' do
    #     configure(no_cache: true)
    #   end
    def restore(solution_or_config, &block)
      common 'restore', %W(#{solution_or_config}), &block
    end

    # Pack project or files into nuget package
    #
    # +nuspec_or_project+:: path to .nuspec or path to .csproj/.fsproj file
    # that should be packaged
    # +&block+:: accepts block with configuration
    #
    #   n.pack 'alpaca.nuspec'
    #   n.pack '/c/solution/alpaca.data/alpaca.data.csproj' do
    #     configure(symbols: true)
    #     configure(properties: 'Configuration=Release')
    #   end
    def pack(nuspec_or_project, &block)
      common 'pack', %W(#{nuspec_or_project}), &block
    end

    # Push nuget package
    #
    # +package+:: path to .nupkg file that should be pushed
    # +&block+:: accepts block with configuration
    #
    #   n.push 'alpaca.0.0.1.nupkg'
    def push(package, &block)
      common 'push', %W(#{package}), &block
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

    private

    def common(command, args, &block)
      instance_eval(&block) if block_given?
      args += configured_attributes_as_arguments('-', ' ')
      if @config && !args.any? { |a| a.start_with?('-ConfigFile') }
        args += ["-ConfigFile #{@config}"]
      end
      execute @exe, [command] + args
      clear_configuration
    end
  end
end
