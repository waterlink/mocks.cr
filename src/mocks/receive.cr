module Mocks
  class Receive
    getter method_name
    getter args

    def initialize(@method_name, @args)
    end

    def and_return(value)
      Message.new(self, value)
    end
  end
end
