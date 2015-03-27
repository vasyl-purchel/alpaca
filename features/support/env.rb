require 'rbconfig'

case RbConfig::CONFIG['host_os']
when /mswin|msys|mingw|cygwin|bccwin|wince|emc/
  @prefix = 'bundle exec ruby '
else
  @prefix = ''
end
