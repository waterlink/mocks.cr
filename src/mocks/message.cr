require "./receive"

module Mocks
  class Message(T, V)
    @receive : Receive(T)
    @value : V

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

    def registry_for_its_args(name)
      receive.registry_for_its_args(name)
    end
  end
end
