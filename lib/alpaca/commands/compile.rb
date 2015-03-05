desc 'Compile solution'
arg_name 'solution_name'
command :compile do |c|
  c.desc 'Build solution in Debug mode'
  c.switch :d, :debug

  c.action do |_, options, args|
    LOG.header 'Compile'
    conf = ('Debug' if options[:d]) || 'Release'
    args = ['**/*.sln'] if args == []
    SLN.find(args) do |s|
      LOG.log s
      LOG.info 'Restoring nuget packages'
      n_c, n_cmd = CONF['Nuget', s.file], 'restore'
      Alpaca::Nuget.new(n_c.exe)
        .execute({}, n_cmd, n_c.options(n_cmd), [s.file])
      LOG.info 'Building solution'
      m_c = CONF['MSBuild', s.file].with(property: { configuration: conf })
      Alpaca::MSBuild.new.execute(m_c, s.file)
    end
  end
end
