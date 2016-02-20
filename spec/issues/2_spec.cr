require "../spec_helper"

module Issue2
  class Application
    def self.exists?(message)
      "wolrd"
    end
  end
end

Mocks.create_mock Issue2::Application do
  mock self.exists?(message)
end

module Issue2
  describe "Application mock" do
    it "works" do
      klass = Mocks.class_double(Issue2::Application)
      allow(klass).to receive(self.exists?("hello")).and_return("world")
      klass.exists?("hello").should eq("world")
    end

    it "works without class double" do
      allow(Application).to receive(self.exists?("hello")).and_return("world")
      Application.exists?("hello").should eq("world")
      Application.exists?("hi").should eq("wolrd")
    end
  end
end
