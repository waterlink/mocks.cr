require "./mocks"

module Mocks
end

def it(description, file = __FILE__, line = __LINE__, &block)
  Mocks.with_reset do
    previous_def(description, file, line, &block)
  end
end
