module Alpaca
  module MSBuild
    # This class provides msbuild configuration
    class Config
      attr_accessor :file, :pre_process, :ignore_project_extensions
      attr_accessor :no_logo, :detailed_summary, :no_autoresponse, :node_reuse
      attr_accessor :version
      attr_accessor :maxcpucount, :toolsversion
      attr_accessor :targets, :properties
      attr_accessor :verbosity, :noconsolelogger

      def initialize(file, &block)
        @file = file
        instance_eval(&block) if block_given?
      end

      def to_s
        args.join(' ').to_s
      end

      def args
        args = %W(#{file})
        args = add_file_system_flags(args)
        args = add_switches(args)
        args = add_compile_flags(args)
        args = add_log_flags(args)
        args = add_targets(args)
        args = add_properties(args)
        args
      end

      private

      def add_file_system_flags(args)
        args += %W(/pp:#{@pre_process}) if @pre_process
        if @ignore_project_extensions
          args += %W(/ignore:#{ignore_project_extensions})
        end
        args
      end

      def add_switches(args)
        args += %w(/ds) if @detailed_summary
        args += %w(/nologo) if @no_logo
        args += %w(/noautorsp) if @no_autoresponse
        args += %w(/ver) if @version
        args += %W(/nr:#{@node_reuse}) unless @node_reuse.nil?
        args
      end

      def add_compile_flags(args)
        args += %W(/m:#{@maxcpucount}) if @maxcpucount
        args += %W(/tv:#{@toolsversion}) if @toolsversion
        args
      end

      def add_log_flags(args)
        args += %W(/v:#{@verbosity}) if @verbosity
        args += %w(/noconlog) if @noconsolelogger
        args
      end

      def add_targets(args)
        args += %W(/t:#{@targets.join(';')}) if @targets
        args
      end

      def add_properties(args)
        if @properties
          props_args = @properties.map { |k, v| "#{k}=#{v}" }.join(';')
          args += %W(/property:#{props_args})
        end
        args
      end
    end
  end
end
