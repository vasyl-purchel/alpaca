desc 'Test solution'
arg_name 'Describe arguments to test here'
command :test do |c|
  c.desc 'Test solution in Debug mode'
  c.switch :d, :debug

  c.desc 'Run tests with OpenCover coverage'
  c.switch :c, :coverage

  c.desc 'Type of generated reports()'
  c.default_value 'default'
  c.flag :f

  c.action do |_, options, args|
    LOG.header 'Test'
    args = ['**/*.sln'] if args == []
    SLN.find(args) do |s|
      LOG.log s
      LOG.info 'Running nunit tests'
      nunit_config = CONF['NUnit', s.file]
      tp = File.dirname(s.file).to_s
      tp += '/Unit.Tests/Wonga.CashIn.Inbound.Unit.Tests.csproj'
      nunit_args = [tp]
      n = Alpaca::NUnit.new nunit_config.exe
      if options[:c]
        opencover_config = CONF['OpenCover', s.file]
        o = Alpaca::OpenCover.new opencover_config.exe, n
        o.execute(opencover_config.options, []) do |t|
          t.execute(nunit_config.options, nunit_args)
        end
      else
        n.execute(nunit_config.options, nunit_args)
      end
    end
  end
end
