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
