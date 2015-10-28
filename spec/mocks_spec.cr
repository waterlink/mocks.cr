require "./spec_helper"

class Example
  def self.hello_world
    "hello world"
  end

  def self.hello_world(greeting)
    "#{greeting} world"
  end

  def say_hello
    "hey!"
  end

  def say_hello(name)
    "hey, #{name}"
  end
end

class AnotherExample
  def self.hello_world
    "yet another hello world"
  end
end

create_mock Example do
  mock self.hello_world
  mock self.hello_world(greeting)
  mock instance.say_hello
  mock instance.say_hello(name)
  mock instance.greeting = value
  mock instance == value
end

create_mock AnotherExample do
  mock self.hello_world
end

create_double "OtherExample" do
  mock self.hello_world as String
  mock self.hello_world(greeting) as String
  mock instance.say_hello as String
  mock instance.say_hello(name) as String
  mock (instance.greeting = value), String
end

create_double "EqualityEdgeCase" do
  mock (instance == other), Bool
end

class SimpleWrapper
  def initialize(@value)
  end

  def ==(other : SimpleWrapper)
    self.value == other.value
  end

  def ==(other)
    false
  end

  protected getter value
end

describe Mocks do
  describe "partial double" do
    it "has original value when there is no mocking" do
      Example.new.say_hello.should eq("hey!")
      Example.new.say_hello("john").should eq("hey, john")
    end

    it "has mocked value when there was some mocking" do
      example = Example.new

      allow(example).to receive(say_hello("world")).and_return("hello, world!")
      example.say_hello("world").should eq("hello, world!")
      example.say_hello("james").should eq("hey, james")

      allow(example).to receive(say_hello).and_return("aloha!")
      example.say_hello.should eq("aloha!")
    end

    it "affects only the same instance" do
      example = Example.new
      allow(example).to receive(say_hello("world")).and_return("hello, world!")

      example2 = Example.new
      example2.say_hello("world").should eq("hey, world")
    end

    it "works with class methods" do
      Example.hello_world.should eq("hello world")

      allow(Example).to receive(self.hello_world).and_return("hey world")
      Example.hello_world.should eq("hey world")

      allow(Example).to receive(self.hello_world("halo")).and_return("halo there world")
      Example.hello_world("halo").should eq("halo there world")
    end

    it "affects only the same class" do
      allow(Example).to receive(self.hello_world).and_return("proudly, hello world")
      AnotherExample.hello_world.should eq("yet another hello world")
    end

    it "returns value of valid type when not mocked" do
      example = Example.new
      typeof(example.say_hello("world")).should eq(String)
    end

    it "returns value of valid type when mocked" do
      example = Example.new
      allow(example).to receive(say_hello("world")).and_return("hello, test")
      typeof(example.say_hello("world")).should eq(String)
    end
  end

  describe "double" do
    it "allows to create double without stubs" do
      example = double("OtherExample")

      allow(example).to receive(say_hello("john")).and_return("halo, john")
      example.say_hello("john").should eq("halo, john")

      allow(example).to receive(say_hello).and_return("halo")
      example.say_hello.should eq("halo")
    end

    it "defines good default #==" do
      a = double("EqualityEdgeCase")
      b = a
      c = double("EqualityEdgeCase")

      a.should eq(b)
      a.should_not eq(c)
      a.should_not eq(59)
    end

    it "works when wrapped in simple object" do
      a = double("EqualityEdgeCase")
      b = double("EqualityEdgeCase")
      c = double("EqualityEdgeCase")
      allow(a).to receive(instance.==(c)).and_return(true)

      SimpleWrapper.new(a).should_not eq(SimpleWrapper.new(b))
      SimpleWrapper.new(a).should eq(SimpleWrapper.new(c))
    end

    it "allows to override default #== gracefully" do
      a = double("EqualityEdgeCase")
      b = double("EqualityEdgeCase")
      allow(a).to receive(instance.==(b)).and_return(true)

      a.should eq(b)
      b.should_not eq(a)
    end

    it "allows to define stubs as an argument" do
      example = double("OtherExample", returns(say_hello("world"), "hello, world!"))
      example.say_hello("world").should eq("hello, world!")
    end

    it "allows for allow syntax" do
      example = double("OtherExample", returns(say_hello("world"), "hello, world!"))
      allow(example).to receive(say_hello("john")).and_return("hi, john")
      example.say_hello("world").should eq("hello, world!")
      example.say_hello("john").should eq("hi, john")
    end

    it "allows to stub class methods" do
      example = double("OtherExample")
      klass = example.class

      expect_raises Mocks::UnexpectedMethodCall, "#{klass.inspect} received unexpected method call self.hello_world[]" do
        klass.hello_world
      end

      allow(klass).to receive(self.hello_world).and_return("aloha world")
      klass.hello_world.should eq("aloha world")
    end

    it "allows to define multiple stubs as an argument list" do
      example = double("OtherExample",
                       returns(say_hello("world"), "hello, world!"),
                       returns(instance.greeting=("hi"), "yes, it is hi"))

      example.say_hello("world").should eq("hello, world!")
      (example.greeting = "hi").should eq("yes, it is hi")
    end

    it "raises UnexpectedMethodCall when there is no such stub" do
      example = double("OtherExample",
                       returns(say_hello("world"), "hello, world!"),
                       returns(instance.greeting=("hi"), "yes, it is hi"))

      expected_message = %{#{example.inspect} received unexpected method call say_hello["john"]}
      expect_raises Mocks::UnexpectedMethodCall, expected_message do
        example.say_hello("john")
      end
    end

    it "returns value of correct type" do
      example = double("OtherExample")
      typeof(example.say_hello("world")).should eq(String)
    end
  end

  describe "instance double" do
    it "can be created without stubs" do
      example = instance_double(Example)
      allow(example).to receive(say_hello("jonny")).and_return("ah, jonny, there you are")
      example.say_hello("jonny").should eq("ah, jonny, there you are")
    end

    it "can be created with stub" do
      example = instance_double(Example, returns(say_hello("james"), "Hi, James!"))
      example.say_hello("james").should eq("Hi, James!")
    end

    it "can be created with a list of stubs" do
      example = instance_double(Example,
                                returns(say_hello("james"), "Hi, James!"),
                                returns(say_hello("john"), "Oh, hey, John."))

      example.say_hello("john").should eq("Oh, hey, John.")
      example.say_hello("james").should eq("Hi, James!")
    end

    it "raises UnexpectedMethodCall when there is no such stub" do
      example = instance_double(Example,
                                returns(say_hello("james"), "Hi, James!"),
                                returns(say_hello("john"), "Oh, hey, John."))

      expected_message = "#{example.inspect} received unexpected method call say_hello[\"sarah\"]"
      expect_raises Mocks::UnexpectedMethodCall, expected_message do
        example.say_hello("sarah")
      end
    end

    it "returns value of correct type" do
      example = instance_double(Example)
      typeof(example.say_hello("world")).should eq(String)
    end
  end

  describe "class double" do
    it "can be created without stubs" do
      example = class_double(Example)
      allow(example).to receive(self.hello_world("hello")).and_return("hello, world")
      example.hello_world("hello").should eq("hello, world")
    end

    it "can be created with a list of stubs" do
      example = class_double(Example,
                             returns(self.hello_world("hello"), "hello, world"),
                             returns(self.hello_world("hey"), "oh, hey, world!"))

      example.hello_world("hello").should eq("hello, world")
      example.hello_world("hey").should eq("oh, hey, world!")
    end

    it "raises UnexpectedMethodCall when there is no such stub" do
      example = class_double(Example,
                             returns(self.hello_world("hello"), "hello, world"),
                             returns(self.hello_world("hey"), "oh, hey, world!"))

      expected_message = "#{example.inspect} received unexpected method call self.hello_world[\"aloha\"]"
      expect_raises Mocks::UnexpectedMethodCall, expected_message do
        example.hello_world("aloha")
      end
    end

    it "can be used to create instance_doubles with .new" do
      example_class = class_double(Example)
      example = example_class.new

      allow(example).to receive(say_hello("john")).and_return("hello, john!")
      example.say_hello("john").should eq("hello, john!")

      expected_message = "#{example.inspect} received unexpected method call say_hello[\"james\"]" 
      expect_raises Mocks::UnexpectedMethodCall, expected_message do
        example.say_hello("james")
      end
    end

    it "returns value of correct type" do
      example = class_double(Example)
      typeof(example.hello_world("hey")).should eq(String)
    end
  end
end
