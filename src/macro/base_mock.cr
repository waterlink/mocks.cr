module Mocks
  module BaseMock
    macro mock(method, flag = :normal)
      {% if flag == :inherited %}
        {% puts "[WARN] mocks.cr: Deprecated usage of ':inherited' flag - this is no longer required" %}
      {% end %}

      {% self_receiver = method.receiver.stringify == "self" %}
      {% original_name = method.name.id %}

      {% method_name = method.name.stringify %}
      {% method_name = "self.#{method_name.id}" if self_receiver %}
      {% method_name = method_name.id %}

      {% equals_method = method_name == "==".id %}

      {% inherited = (!equals_method && !self_receiver && !@type.methods.map(&.name).includes?(original_name)) || flag == :inherited %}
      {% inherited = inherited || (self_receiver && !@type.class.methods.map(&.name).includes?(original_name)) %}

      {% previous = (inherited ? :super : :previous_def).id %}

      def {{method_name}}({{method.args.splat}})
        %mock_name = @@__mocks_name
        unless %mock_name
          raise "Assertion failed (mocks.cr): @@__mocks_name can not be nil"
        end

        {% if method.args.empty? %}
          {% args_splat_notype = method.args.splat %}
          {% args_tuple = "nil".id %}
          {% args_tuple_notype = "nil".id %}
        {% else %}
          {% if method.args.splat.stringify.includes?(",") %}
            {% args_splat_notype = method.args.splat.stringify.split(",").map {|arg| arg.split(":")[0].strip}.join(", ") %}
          {% else %}
            {% args_splat_notype = method.args.splat.stringify.split(":")[0].strip %}
          {% end %}
          {% args_tuple = "{#{method.args.splat}}".id %}
          {% args_tuple_notype = "{#{args_splat_notype.id}}".id %}
        {% end %}

        {% args_types = "typeof(#{args_tuple})".id %}
        {% args_notype_types = "typeof(#{args_tuple_notype})".id %}

        ::Mocks::Registry.remember({{args_types}})

        %method = ::Mocks::Registry({{args_notype_types}}).for(%mock_name).fetch_method({{method_name.stringify}})
        %result = %method.call(::Mocks::Registry::ObjectId.build(self), {{args_tuple_notype}})

        if %result.call_original
          {{previous}}
        else
          if %result.value.is_a?(typeof({{previous}}))
            %result.value.as(typeof({{previous}}))
          else
            %type_error = "#{self.inspect} attempted to return stubbed value of wrong type, while calling"
            %type_error_detail = "Expected type: #{typeof({{previous}})}. Actual type: #{ %result.value.class }"
            raise ::Mocks::UnexpectedMethodCall.new(
              {% if method.args.empty? %}
                "#{ %type_error } {{method_name}}[]. #{ %type_error_detail }"
              {% else %}
                "#{ %type_error } {{method_name}}#{[{{args_splat_notype.id}}]}. #{ %type_error_detail }"
              {% end %}
            )
          end
        end
      end
    end
  end
end
