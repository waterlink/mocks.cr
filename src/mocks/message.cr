module Mocks
  class Message
    getter receive
    getter value

    def initialize(@receive, @value)
    end

    def method_name
      receive.method_name
    end

    def args
      receive.args
    end
  end
end
