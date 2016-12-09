module Mocks
  module Macro
    module GlobalDSL
      macro receive(method)
        {% method_name = method.name.id %}
        {% method_name = "self.#{method_name}" if method.receiver.stringify == "self" %}
        {% method_name = method_name.id %}

        {% if method.args.empty? %}
          ::Mocks::Receive(Nil).new("{{method_name}}", nil)
        {% else %}
          {% args_tuple = "{#{method.args.splat}}".id %}
          {% args_types = "typeof(#{args_tuple})".id %}
          ::Mocks::Receive({{args_types}}).new("{{method_name}}", {{args_tuple}})
        {% end %}
      end

      macro have_received(method)
        ::Mocks::HaveReceivedExpectation.new(receive({{method}}))
      end

      macro returns(method, and_return)
        receive({{method}}).and_return({{and_return}})
      end

      def allow(subject)
        ::Mocks::Allow.new(subject)
      end
    end

    include GlobalDSL

    macro double(name, *stubs)
      {% if stubs.empty? %}
      ::Mocks::Doubles::{{name.id}}.new
      {% else %}
      ::Mocks::Doubles::{{name.id}}.new({{stubs}})
      {% end %}
    end

    macro instance_double(name, *stubs)
      {% if stubs.empty? %}
      ::Mocks::InstanceDoubles{{name.id}}.new
      {% else %}
      ::Mocks::InstanceDoubles{{name.id}}.new({{stubs}})
      {% end %}
    end

    macro class_double(name, *stubs)
      {% if stubs.empty? %}
      ::Mocks::InstanceDoubles{{name.id}}
      {% else %}
      ::Mocks::Allow.with_stubs(::Mocks::InstanceDoubles{{name.id}}, {{stubs}})
      {% end %}
    end
  end
end
