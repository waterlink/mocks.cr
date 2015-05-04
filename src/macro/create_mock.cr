macro create_mock(name, &block)
  class {{name.id}}
    @@__mocks_name = "{{name.id}}"

    include ::Mocks::BaseMock
    {{block.body}}
  end

  module ::Mocks
    module InstanceDoubles
      class {{name.id}} < ::Mocks::BaseDouble
        @@name = "Mocks::InstanceDoubles::{{name.id}}"

        def ==(other)
          self.same?(other)
        end

        def ==(other : Value)
          false
        end

        {{block.body}}
      end
    end
  end
end
