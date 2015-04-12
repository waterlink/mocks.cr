# mocks

General purpose mocking library for Crystal.

## Installation

Add it to `Projectfile`

```crystal
deps do
  github "waterlink/mocks.cr"
end
```

## Usage

```crystal
require "mocks"
```

### Partial double

```crystal
class Example
  def say_hello(name)
    "hey, #{name}"
  end
end

create_mock Example do
  mock say_hello(name)
end

example = Example.new
allow(example).to receive(say_hello(name)).with("world").and_return("hello, world!")

example.say_hello("world")    #=> "hello, world!"
example.say_hello("john")     #=> "hey, john"
```

### Double

**Not implemented yet**

```crystal
create_double "Example" do
  mock say_hello(name)
  mock greeting=(value)
end

example = double("Example", say_hello(name) => "hello")
allow(example).to receive(greeting=(name)).and_return("hey")
```

### Instance double

TODO: Come up with usage for instance doubles

### Class double

TODO: Come up with usage for class doubles (if they are needed at all)

## Development

TODO: Write instructions for development

## Contributing

1. Fork it ( https://github.com/waterlink/mocks.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [waterlink](https://github.com/waterlink) Oleksii Fedorov - creator, maintainer
