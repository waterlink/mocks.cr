module Mocks
  module BaseMock
    macro mock(method, flag = :normal)
      {% self_receiver = method.receiver.stringify == "self" %}

      {% method_name = method.name.stringify %}
      {% method_name = "self.#{method_name.id}" if self_receiver %}
      {% method_name = method_name.id %}

      {% inherited = (!self_receiver && !@type.methods.map(&.name).includes?(method_name)) || flag == :inherited %}
      {% previous = (inherited ? :super : :previous_def).id %}

      def {{method_name}}({{method.args.argify}})
        %mock_name = @@__mocks_name
        unless %mock_name
          raise "Assertion failed (mocks.cr): @@__mocks_name can not be nil"
        end

        %method = ::Mocks::Registry.for(%mock_name).fetch_method({{method_name.stringify}})
        {% if method.args.empty? %}
          %result = %method.call(::Mocks::Registry::ObjectId.build(self))
        {% else %}
          %result = %method.call(::Mocks::Registry::ObjectId.build(self), {{method.args}})
        {% end %}

        if %result.call_original
          {{previous}}
        else
          if %result.value.is_a?(typeof({{previous}}))
            %result.value as typeof({{previous}})
          else
            %type_error = "#{self.inspect} attempted to return stubbed value of wrong type, while calling"
            %type_error_detail = "Expected type: #{typeof({{previous}})}. Actual type: #{ %result.value.class }"
            raise ::Mocks::UnexpectedMethodCall.new(
              {% if method.args.empty? %}
                "#{ %type_error } {{method_name}}[]. #{ %type_error_detail }"
              {% else %}
                "#{ %type_error } {{method_name}}#{[{{method.args.argify}}]}. #{ %type_error_detail }"
              {% end %}
            )
          end
        end
      end
    end
  end
end
