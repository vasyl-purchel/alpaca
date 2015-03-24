require 'alpaca/log'
require 'alpaca/solutions'

module Alpaca
  # Class *Application* provides methods that can
  # be used by CLI and from REPL sessions
  class Application
    include Log

    def compile(pattern: DEFAULT_SOLUTIONS_PATTERN, debug: false)
      header 'Compile'
      Solutions.each(pattern) do |solution|
        log solution
        solution.compile(debug)
      end
    end

    def test(pattern: DEFAULT_SOLUTIONS_PATTERN,
             debug: false,
             coverage: false,
             category: 'all')
      header 'Test'
      Solutions.each(pattern) do |solution|
        log solution
        solution.test(debug, coverage, category)
      end
    end

    def report(pattern: DEFAULT_SOLUTIONS_PATTERN, category: 'all')
      header 'Report'
      Solutions.each(pattern) do |solution|
        log solution
        solution.report(category)
      end
    end

    def pack(pattern: DEFAULT_SOLUTIONS_PATTERN)
      header 'Pack'
      Solutions.each(pattern) do |solution|
        log solution
        solution.pack
      end
    end

    def release(pattern: DEFAULT_SOLUTIONS_PATTERN, push: true)
      header 'Release'
      Solutions.each(pattern) do |solution|
        log solution
        solution.release(push)
      end
    end

    def push(pattern: DEFAULT_SOLUTIONS_PATTERN, force: false)
      header 'Push'
      Solutions.each(pattern) do |solution|
        log solution
        solution.push(force)
      end
    end
  end
end
