require 'alpaca/log'
require 'alpaca/solutions'

module Alpaca
  # Class *Application* provides methods that can
  # be used by CLI
  class Application
    DEFAULT_SOLUTIONS_PATTERN = ['**/*.sln', '**/Assets']

    include Log

    # Runs compile against each found solution by pattern
    #
    # +[pattern]+:: pattern to find a solution(Array can be used)
    # +[debug]+:: switch to compile solution in debug mode (false by default)
    def compile(pattern = DEFAULT_SOLUTIONS_PATTERN, debug = false)
      log.header 'Compile'
      Solutions.each(pattern) do |solution|
        log.puts solution
        solution.compile(debug)
      end
    end

    # Runs tests against each found solution by pattern
    #
    # +[pattern]+:: pattern to find a solution(Array can be used)
    # +[debug]+:: switch to run solution tests in debug mode (false by default)
    # +[coverage]+:: switch to run coverage (false by default)
    # +[category]+:: tests category - smoke, unit, service... (all by default)
    def test(pattern = DEFAULT_SOLUTIONS_PATTERN,
             debug = false,
             coverage = false,
             category = 'all')
      log.header 'Test'
      Solutions.each(pattern) do |solution|
        log.puts solution
        solution.test(debug, coverage, category)
      end
    end

    def report(pattern = DEFAULT_SOLUTIONS_PATTERN, category = 'all')
      log.header 'Report'
      Solutions.each(pattern) do |solution|
        log.puts solution
        solution.report(category)
      end
    end

    def pack(pattern = DEFAULT_SOLUTIONS_PATTERN)
      log.header 'Pack'
      Solutions.each(pattern) do |solution|
        log.puts solution
        solution.pack
      end
    end

    def release(pattern = DEFAULT_SOLUTIONS_PATTERN, push = true)
      log.header 'Release'
      Solutions.each(pattern) do |solution|
        log.puts solution
        solution.release(push)
      end
    end

    def push(pattern = DEFAULT_SOLUTIONS_PATTERN, force = false)
      log.header 'Push'
      Solutions.each(pattern) do |solution|
        log.puts solution
        solution.push(force)
      end
    end

    def configure_global(properties)
      log.header 'Configure'
      Configuration.set(properties)
    end

    def configure_local(pattern = DEFAULT_SOLUTIONS_PATTERN, properties)
      log.header 'Configure'
      Solutions.each(pattern) do |solution|
        log solution
        Configuration.new(solution).set(properties)
      end
    end
  end
end
