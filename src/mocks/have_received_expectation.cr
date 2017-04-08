module Mocks
  class HaveReceivedExpectation(T)
    def initialize(@receive : Receive(T))
    end

    def match(target)
      method(target).received?(oid(target), @receive.args)
    end

    def failure_message(target)
      "expected: #{expected}\n     got: #{got(target)}"
    end

    def negative_failure_message(target)
      "expected: receive != #{expected}\n     got: #{got(target)}"
    end

    private def method(target)
      @receive
        .registry_for_its_args(target_class_name(target))
        .fetch_method(@receive.method_name)
    end

    private def self_method?
      @receive.method_name.starts_with?("self.")
    end

    private def target_class_name(target)
      return target.name if self_method? && target.is_a?(Class)
      target.class.name
    end

    private def oid(target)
      Registry::ObjectId.build(target)
    end

    private def got(target)
      if args = last_args(target)
        return "#{@receive.method_name}#{args}"
      end

      "nil"
    end

    def expected
      "#{@receive.method_name}#{expected_args}"
    end

    def expected_args
      (@receive.args || [] of String).to_a.inspect
    end

    private def last_args(target)
      method(target).last_received_args(oid(target))
    end
  end
end
