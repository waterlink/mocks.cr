module Mocks
  module Macro
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

            def hash
              object_id
            end

            macro mock(*args)
              _mock(\{{args.splat}})
            end

            {{block.body}}
          end
        end
      end
    end
  end
end
