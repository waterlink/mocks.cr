# mocks [![Build Status](https://travis-ci.org/waterlink/mocks.cr.svg?branch=master)](https://travis-ci.org/waterlink/mocks.cr)

General purpose mocking library for Crystal.

## Installation

Add it to `shard.yml`:

```yaml
dependencies:
  mocks:
    github: waterlink/mocks.cr
    version: ~> 0.9
```

This shard requires version of Crystal minimum `0.13.0`.

## Usage

```crystal
require "mocks"
```

### Usage with `spec` library

```crystal
require "mocks/spec"
```

This will automatically register `Mocks.reset` hooks in `before_each` and
`after_each`. Additionally it makes `allow`, `receive` and `have_received`
available in global scope.

If you need all of macros (such as: `create_mock, create_double, double,
instance_double, etc.`) to be available in global scope use `include
::Mocks::Macro`.

### Usage with `spec2` library

First add [`spec2-mocks`](https://github.com/waterlink/spec2-mocks.cr) to your
dependencies:

```yaml
dependencies:
  mocks:
    github: waterlink/mocks.cr
  spec2:
    github: waterlink/spec2.cr
  spec2-mocks:
    github: waterlink/spec2-mocks.cr
```

Run `crystal deps update` and do:

```crystal
require "spec2-mocks"
```

This should be enough to start using mocks together with spec2.

### Partial double

```crystal
class Example
  def say_hello(name)
    "hey, #{name}"
  end
end

Mocks.create_mock Example do
  mock say_hello(name)
  # or
  # mock instance.say_hello(name)
end

example = Example.new
allow(example).to receive(say_hello("world")).and_return("hello, world!")

example.say_hello("world")    #=> "hello, world!"
example.say_hello("john")     #=> "hey, john"
```

If you want to mock operators or setters, syntax is pretty straightforward:

```crystal
# setter
mock instance.greeting = value
# or
mock instance.greeting=(value)

# equals
mock instance == other
# or
mock instance.==(other)
```

#### Class methods

Just use `mock self.method_name(args..)`

```crystal
Mocks.create_mock Example do
  mock self.hello_world(greeting)
end

allow(Example).to receive(self.hello_world("aloha")).and_return("aloha (as 'hello'), world!")
Example.hello_world("hey")         # => "hey, world!"                   (original was called)
Example.hello_world("aloha")       # => "aloha (as 'hello'), world!"    (mock was called)
```

#### Module methods

Just use `mock self.method_name(args..)`

```crystal
module Example
  def self.hello_world(greeting)
    greeting
  end
end

Mocks.create_module_mock Example do
  mock self.hello_world(greeting)
end

allow(Example).to receive(self.hello_world("aloha")).and_return("aloha (as 'hello'), world!")
```

#### Mocking Struct

```crystal
struct Example
  def now
    Time.now
  end
end

Mocks.create_struct_mock Example do
  mock now
end

example = Example.new
allow(example).to receive(now).and_return(Time.new(2014, 12, 22))
```

### Double

Caution: doubles require return types.

```crystal
Mocks.create_double "OtherExample" do
  mock say_hello(name).as(String)
  mock greetings_count.as(Int64)

  # For setters and operators this is the only syntax allowed:
  # ( parenthesis are mandatory not to confuse Crystal's parser )
  mock (instance.greeting = value), String
  mock (instance == other), Bool
end

example = Mocks.double("OtherExample", returns(say_hello("world"), "hello world!"))
allow(example).to receive(instance.greeting=("hey")).and_return("hey")

example.say_hello("world")     #=> "hello world!"
example.say_hello("john")      #=> Mocks::UnexpectedMethodCall: #<Mocks::Doubles::OtherExample:0x109498F00> received unexpected method call say_hello["john"]
```

### Instance double

After defining `Example`'s mock with `create_mock` you can use it as an `instance_double`:

```crystal
example = Mocks.instance_double(Example, returns(say_hello("world"), "hello, world!"))
allow(example).to receive(say_hello("sarah")).and_return("Hey, Sarah!")

example.say_hello("world")     #=> "hello world!"
example.say_hello("sarah")     #=> "Hey, Sarah!"
example.say_hello("john")      #=> Mocks::UnexpectedMethodCall: #<Mocks::InstanceDoubles::Example:0x109498F00> received unexpected method call say_hello["john"]
```

### Class double

After defining `Example`'s mock with `create_mock` you can use it as a `class_double`:

```crystal
example_class = Mocks.class_double(Example, returns(self.hello_world("aloha"), "aloha, world!"))
allow(example_class).to receive(self.hello_world("hi")).and_return("hey, world!")

example_class.hello_world("aloha")            # => "aloha, world!"
example_class.hello_world("hi")               # => "hey, world!"
example_class.hello_world("halo")             # => Mocks::UnexpectedMethodCall: Mocks::InstanceDoubles::Example received unexpected method call self.hello_world["halo"]
```

#### .new

It returns normal `instance_double`:

```crystal
example_class = Mocks.class_double(Example)
example_class.new          # => #<Mocks::InstanceDoubles::Example:0x109498F00>
```

### HaveReceived expectation (usage with stdlib `spec`)

```crystal
example = Example.new
example.say("hello")
example.should have_received(say("hello"))   # passes
example.should have_received(say("hi"))      # fails
```

## Development

After cloning the project:

```
cd mocks.cr
crystal deps   # install dependencies
crystal spec   # run specs
```

Just use normal TDD development style.

## Contributing

1. Fork it ( https://github.com/waterlink/mocks.cr/fork )
2. Create your feature branch (git checkout -b my-new-feature)
3. Commit your changes (git commit -am 'Add some feature')
4. Push to the branch (git push origin my-new-feature)
5. Create a new Pull Request

## Contributors

- [waterlink](https://github.com/waterlink) Oleksii Fedorov - creator, maintainer
