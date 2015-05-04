macro create_mock(name, &block)
  class {{name.id}}
    @@__mocks_name = "{{name.id}}"

    include ::Mocks::BaseMock
    {{block.body}}
  end
end
