require "./mocks/*"

module Mocks
  extend self

  def with_reset
    reset
    yield
    reset
  end

  def reset
  end
end

macro create_mock(name, &block)
  class {{name.id}}
    macro mock(method)
      def \{{method.id}}
        method = Mocks::Registry.for("{{name.id}}").fetch_method("\{{method.name}}")
        result = method.call(object_id, \{{method.args}})
        if result.call_original
          previous_def(\{{method.args.argify}})
        else
          result.value
        end
      end
    end

    {{block.body}}
  end
end

macro receive(method)
  Mocks::Receive.new("{{method.name}}", {{method.args}})
end

def allow(subject)
  Mocks::Allow.new(subject)
end
