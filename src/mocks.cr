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

  class UnexpectedMethodCall < Exception; end
end

macro create_mock(name, &block)
  class {{name.id}}
    macro mock(method)
      def \{{method.name}}(\{{method.args.argify}})
        method = ::Mocks::Registry.for("{{name.id}}").fetch_method("\{{method.name}}")
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
  ::Mocks::Receive.new("{{method.name}}", {{method.args}})
end

macro returns(method, and_return)
  receive({{method}}).and_return({{and_return}})
end

def allow(subject)
  ::Mocks::Allow.new(subject)
end

macro create_double(name, &block)
  module ::Mocks
    module Doubles
      class {{name.id}}
        def initialize
        end

        def initialize(stubs)
          stubs.each do |stub|
            allow(self).to stub
          end
        end

        def ==(other)
          self.same?(other)
        end

        def ==(other : Value)
          false
        end

        macro mock(method)
          def \{{method.name}}(\{{method.args.argify}})
            method = ::Mocks::Registry.for("Mocks::Doubles::{{name.id}}").fetch_method("\{{method.name}}")
            result = method.call(object_id, \{{method.args}})
            if result.call_original
              \{% if method.name.stringify == "==" %}
                previous_def
              \{% else %}
                raise ::Mocks::UnexpectedMethodCall.new(
                  "#{self.inspect} received unexpected method call \{{method.name}}#{[\{{method.args.argify}}]}"
                )
              \{% end %}
            else
              result.value
            end
          end
        end

        {{block.body}}
      end
    end
  end
end

macro double(name, *stubs)
  {% if stubs.empty? %}
  ::Mocks::Doubles::{{name.id}}.new
  {% else %}
  ::Mocks::Doubles::{{name.id}}.new({{stubs}})
  {% end %}
end
