macro create_double(name, &block)
  module ::Mocks
    module Doubles
      class {{name.id}} < ::Mocks::BaseDouble
        @@name = "Mocks::Doubles::{{name.id}}"

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
