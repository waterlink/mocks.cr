require "./spec_helper"

class Example
  def say_hello(name)
    "hey, #{name}"
  end
end

create_mock Example do
  mock instance.say_hello(name)
end

create_double "OtherExample" do
  mock instance.say_hello(name)
  mock instance.greeting=(value)
end

describe Mocks do
  describe "partial double" do
    it "has original value when there is no mocking" do
      Example.new.say_hello("john").should eq("hey, john")
    end

    it "has mocked value when ther was some mocking" do
      example = Example.new
      allow(example).to receive(say_hello("world")).and_return("hello, world!")

      example.say_hello("world").should eq("hello, world!")
      example.say_hello("james").should eq("hey, james")
    end

    it "affects only the same instance" do
      example = Example.new
      allow(example).to receive(say_hello("world")).and_return("hello, world!")

      example2 = Example.new
      example2.say_hello("world").should eq("hey, world")
    end
  end

  describe "double" do
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

      expect_raises Mocks::UnexpectedMethodCall, "#{example.inspect} received unexpected method call say_hello[\"john\"]" do
        example.say_hello("john")
      end
    end
  end
end
