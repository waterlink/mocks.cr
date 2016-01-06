require "../spec_helper"

class Issue2Application
  def self.exists?(message)
    "wolrd"
  end
end

create_mock Issue2Application do
  mock self.exists?(message)
end

module Issue2
  describe "Application mock" do
    it "works" do
      klass = class_double(Issue2Application)
      allow(klass).to receive(self.exists?("hello")).and_return("world")
      klass.exists?("hello").should eq("world")
    end

    it "works without class double" do
      allow(Issue2Application).to receive(self.exists?("hello")).and_return("world")
      Issue2Application.exists?("hello").should eq("world")
      Issue2Application.exists?("hi").should eq("wolrd")
    end
  end
end
