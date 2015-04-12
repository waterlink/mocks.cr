require "./spec_helper"

class Example
  def say_hello(name)
    "hey, #{name}"
  end
end

create_mock Example do
  mock say_hello(name)
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
end
