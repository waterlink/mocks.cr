require "../spec_helper"

class Base
  def hello
    "Hello"
  end

  def self.hello
    "self.Hello"
  end
end

class Derived < Base
end

Mocks.create_mock Derived do
  mock hello
  mock self.hello
end

module BaseModule
  def hello
    "a self hello"
  end
end

module DerivedModule
  extend BaseModule
end

Mocks.create_module_mock DerivedModule do
  mock self.hello
end

abstract struct StructBase
  def add(x)
    37
  end

  def self.add(x)
    53
  end
end

struct StructDerived < StructBase
end

Mocks.create_struct_mock StructDerived do
  mock add(x)
  mock self.add(x)
end

describe "Inheritance" do
  it "works with instance methods" do
    d = Derived.new
    allow(d).to receive(hello).and_return("world")
    d.hello.should eq("world")
  end

  it "works with class methods" do
    allow(Derived).to receive(self.hello).and_return("world")
    Derived.hello.should eq("world")
  end

  it "works with module methods" do
    allow(DerivedModule).to receive(self.hello).and_return("modularized hello")
    DerivedModule.hello.should eq("modularized hello")
  end

  it "works with struct instance methods" do
    s = StructDerived.new
    allow(s).to receive(add(7)).and_return(42)
    s.add(7).should eq(42)
  end

  it "works with struct class methods" do
    allow(StructDerived).to receive(self.add(7)).and_return(42)
    StructDerived.add(7).should eq(42)
  end
end
