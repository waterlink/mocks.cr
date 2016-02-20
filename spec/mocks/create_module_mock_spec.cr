require "../spec_helper"

module MyModule
  def self.exists?(name)
    false
  end
end

Mocks.create_module_mock MyModule do
  mock self.exists?(name)
end

Mocks.create_mock File do
  mock self.exists?(name)
end

describe "create module mock macro" do
  it "does not fail with Nil errors" do
    allow(MyModule).to receive(self.exists?("hello")).and_return(true)
    MyModule.exists?("world").should eq(false)
    MyModule.exists?("hello").should eq(true)
  end

  it "does not fail with Nil errors for stdlib class" do
    allow(File).to receive(self.exists?("hello")).and_return(true)
    File.exists?("world").should eq(false)
    File.exists?("hello").should eq(true)
  end
end
