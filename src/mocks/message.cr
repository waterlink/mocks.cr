require "./receive"

module Mocks
  class Message(T)
    @receive :: Receive
    @value :: T

    getter receive
    getter value

    def initialize(@receive, @value : T)
    end

    def method_name
      receive.method_name
    end

    def args
      receive.args
    end
  end
end
