require "./registry"

module Mocks
  class Receive
    @method_name :: String
    getter method_name
    #@args :: ???
    getter args

    def initialize(@method_name, @args = Registry::NoArgs.new)
    end

    def and_return(value)
      Message.new(self, value)
    end
  end
end
