require "./mocks/*"
require "./macro/*"

module Mocks
  extend self

  def with_reset
    reset
    yield
    reset
  end

  def reset
  end

  class UnexpectedMethodCall < Exception; end

  class BaseDouble
    def initialize
    end

    def initialize(stubs)
      stubs.each do |stub|
        allow(self).to stub
      end
    end

    def same?(other : Value)
      false
    end
  end
end
