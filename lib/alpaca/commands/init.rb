desc 'Initialize new solution'
arg_name 'Describe arguments to init here'
command :init do |c|
  c.desc 'Describe a switch to init'
  c.switch :s

  c.desc 'Describe a flag to init'
  c.default_value 'default'
  c.flag :f
  c.action do |_, options, args|
    LOG.header 'Init'
    LOG.log "init command ran with #{options}, #{args}"
    conf = CONF['Gerrit']
    ssh = Alpaca::Ssh.new(Alpaca::Gerrit.new)
    ssh.execute(conf.options, conf['user'].config, conf['host'].config) do |g|
      g.execute({}, 'ls-groups', {}, [])
    end
    Alpaca::Git.new.execute({}, 'status', {}, [])
  end
end
