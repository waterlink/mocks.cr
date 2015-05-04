require "./registry"

module Mocks
  class Receive
    getter method_name
    getter args

    def initialize(@method_name, @args = Registry::NoArgs.new)
    end

    def and_return(value)
      Message.new(self, value)
    end
  end
end
