# This module can be used to make mocking
# easier and reduce code length
module Helpers
  def mock_os(os)
    mock_env('windir', 'C:\WINDOWS')
    allow(RbConfig::CONFIG).to receive(:[])
      .with('host_os')
      .and_return(get_host_os(os))
  end

  def normalize_path(path)
    File.expand_path(path).downcase
  end

  def mock_env(key, value)
    allow(ENV).to receive(:key?)
      .with(key)
      .and_return(!value.nil?)
    allow(ENV).to receive(:[])
      .with(key)
      .and_return(value)
  end

  def get_host_os(os)
    case os
    when :windows then 'mingw32'
    when :macos then 'mac os'
    when :linux then 'linux'
    when :unix then 'bsd'
    else
      fail "unknown os: #{os}"
    end
  end
end
