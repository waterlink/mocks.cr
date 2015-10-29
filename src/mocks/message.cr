require "./receive"

module Mocks
  class Message(T, V)
    @receive :: Receive(T)
    @value :: V

    getter receive
    getter value

    def initialize(@receive : Receive(T), @value : V)
    end

    def method_name
      receive.method_name
    end

    def args
      receive.args
    end
  end
end
