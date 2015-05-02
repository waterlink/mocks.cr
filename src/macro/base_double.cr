module Mocks
  class BaseDouble
    macro mock(method)
      def {{method.name}}({{method.args.argify}})
        method = ::Mocks::Registry.for(@@name).fetch_method("{{method.name}}")
        result = method.call(object_id, {{method.args}})
        if result.call_original
          {% if method.name.stringify == "==" %}
            previous_def
          {% else %}
            raise ::Mocks::UnexpectedMethodCall.new(
              "#{self.inspect} received unexpected method call {{method.name}}#{[{{method.args.argify}}]}"
            )
          {% end %}
        else
          result.value
        end
      end
    end
  end
end
