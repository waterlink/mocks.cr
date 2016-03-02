module Mocks
  class BaseDouble
    macro _mock(method_spec, return_type = nil, sample = nil)
      {% if sample %}
        {% method = method_spec %}

        {% method_name = method.name.stringify %}
        {% method_name = "self.#{method_name.id}" if method.receiver.stringify == "self" %}
        {% method_name = method_name.id %}

        {% if method.receiver.stringify == "self" %}
             {% return_type = "typeof(typeof(#{sample}).#{method.name}(#{method.args.argify}))" %}
        {% else %}
             {% return_type = "typeof(#{sample}.#{method.name}(#{method.args.argify}))".id %}
        {% end %}
      {% else %}

        {% if return_type %}
          {% method = method_spec %}
        {% else %}
          {% raise %{create_double's `mock` requires type annotation.
                     Format: mock #{method_spec} as ReturnTypeHere
          } unless method_spec.is_a?(Cast) %}

          {% method = method_spec.obj %}
          {% return_type ||= method_spec.to %}
        {% end %}

        {% method_name = method.name.stringify %}
        {% method_name = "self.#{method_name.id}" if method.receiver.stringify == "self" %}
        {% method_name = method_name.id %}
      {% end %}

      def {{method_name}}({{method.args.argify}})
        %method = ::Mocks::Registry.for(@@name).fetch_method("{{method_name}}")

        {% if method.args.empty? %}
          %result = %method.call(::Mocks::Registry::ObjectId.build(self))
        {% else %}
          %result = %method.call(::Mocks::Registry::ObjectId.build(self), [{{method.args.argify}}])
        {% end %}

        if %result.call_original

          {% if method_name.stringify == "==" %}
            previous_def as {{return_type.id}}
          {% else %}

            raise ::Mocks::UnexpectedMethodCall.new(
              {% if method.args.empty? %}
                "#{self.inspect} received unexpected method call {{method_name}}[]"
              {% else %}
                "#{self.inspect} received unexpected method call {{method_name}}#{[{{method.args.argify}}]}"
              {% end %}
            )

          {% end %}

        else
          if %result.value.is_a?({{return_type.id}})
            %result.value as {{return_type.id}}
          else
            raise ::Mocks::UnexpectedMethodCall.new(
              {% if method.args.empty? %}
                "#{self.inspect} received unexpected method call {{method_name}}[]"
              {% else %}
                "#{self.inspect} received unexpected method call {{method_name}}#{[{{method.args.argify}}]}"
              {% end %}
            )
          end
        end
      end
    end
  end
end
