require 'rbconfig'

module Alpaca
  # Detect OS
  module Os
    def self.os
      @os ||= (
        host_os = RbConfig::CONFIG['host_os']
        get_os(host_os)
      )
    end

    def self.get_os(host_os)
      case host_os
      when /mswin|msys|mingw|cygwin|bccwin|wince|emc/ then :windows
      when /darwin|mac os/ then :macosx
      when /linux/ then :linux
      when /solaris|bsd/ then :unix
      else
        fail "unknown os: #{host_os.inspect}"
      end
    end

    private_class_method :get_os
  end
end
