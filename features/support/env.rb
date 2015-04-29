require 'rbconfig'

def prefix
  case RbConfig::CONFIG['host_os']
  when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
    'bundle exec ruby bin/'
  else
    'bin/'
  end
end
