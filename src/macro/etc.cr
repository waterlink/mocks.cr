macro receive(method)
  ::Mocks::Receive.new("{{method.name}}", {{method.args}})
end

macro returns(method, and_return)
  receive({{method}}).and_return({{and_return}})
end

def allow(subject)
  ::Mocks::Allow.new(subject)
end

macro double(name, *stubs)
  {% if stubs.empty? %}
  ::Mocks::Doubles::{{name.id}}.new
  {% else %}
  ::Mocks::Doubles::{{name.id}}.new({{stubs}})
  {% end %}
end
