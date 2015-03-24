require 'alpaca/log'

module Alpaca
  # Unity3D solution
  class UnitySolution
    include Log

    def initialize(_)
    end

    def compile(debug)
      info "Compiling in #{debug ? 'debug' : 'release'} mode"
    end

    def test(debug, _, category)
      mode = debug ? 'Debug' : 'Release'
      info "testing in #{mode} mode for category #{category}.."
    end

    def report(category)
      info "generating report for category #{category}.."
    end

    def pack
      info 'creating packages :O'
    end

    def release(push)
      info "releasing package#{push ? ' and pushing it' : ''}"
    end

    def push(force)
      info "#{force ? 'force ' : ''}pushing package"
    end
  end
end
