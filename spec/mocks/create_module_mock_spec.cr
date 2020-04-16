require "../spec_helper"

module MyModule
  def self.exists?(name)
    "an unchanged value"
  end
end

Mocks.create_module_mock MyModule do
  mock self.exists?(name)
end

Mocks.create_mock File do
  mock self.exists?(name)
end

describe "::allow Macro" do
  context "When mocking a method on a custom class" do
    before_each do
      allow(MyModule).to receive(self.exists?("hello")).and_return("the changed value")
    end
    it "responds with changed value for a mocked signature" do
      MyModule.exists?("hello").should eq("the changed value")
    end
    it "responds with unchanged value for an unmocked signature" do
      MyModule.exists?("world").should eq("an unchanged value")
    end
  end
  context "When mocking a method on a stdlib class" do
    before_each do
      allow(File).to receive(self.exists?("hello")).and_return(true)
    end

    it "responds with changed value for a mocked signature" do
      File.exists?("hello").should eq(true)
    end
    it "responds with unchanged value for an unmocked signature" do
      File.exists?("world").should eq(false)
    end
  end
end
