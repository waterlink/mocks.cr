module Mocks
  module BaseMock
    macro mock(method)
      {% method_name = method.name.stringify %}
      {% method_name = "self.#{method_name.id}" if method.receiver.stringify == "self" %}
      {% method_name = method_name.id %}

      def {{method_name}}({{method.args.argify}})
        %method = ::Mocks::Registry.for(@@__mocks_name).fetch_method({{method_name.stringify}})
        {% if method.args.empty? %}
          %result = %method.call(::Mocks::Registry::ObjectId.build(self))
        {% else %}
          %result = %method.call(::Mocks::Registry::ObjectId.build(self), {{method.args}})
        {% end %}

        if %result.call_original
          previous_def
        else
          if %result.value.is_a?(typeof(previous_def))
            %result.value as typeof(previous_def)
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
